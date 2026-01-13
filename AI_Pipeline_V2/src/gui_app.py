
import tkinter as tk
from tkinter import filedialog, ttk
from PIL import Image, ImageTk
import threading
from pathlib import Path
from inference_pipeline import InferencePipeline

class HousepitalApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Housepital-AI Inference System")
        self.root.geometry("1000x700")
        
        # Initialize Logic
        self.pipeline = None
        self.pipeline_ready = False
        
        # Layout
        self.setup_ui()
        
        # Load Model in Background
        self.log("Initializing Pipeline models... Please wait.")
        threading.Thread(target=self.load_pipeline, daemon=True).start()

    def setup_ui(self):
        # Top Frame for Image
        self.top_frame = tk.Frame(self.root)
        self.top_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Left: Image Display
        self.img_label = tk.Label(self.top_frame, text="No Image Selected", bg="gray")
        self.img_label.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Right: Results
        self.result_text = tk.Text(self.top_frame, width=40, font=("Consolas", 10))
        self.result_text.pack(side=tk.RIGHT, fill=tk.Y, padx=(10, 0))
        
        # Bottom Frame for Controls
        self.bottom_frame = tk.Frame(self.root)
        self.bottom_frame.pack(fill=tk.X, padx=10, pady=10)
        
        self.btn_load = tk.Button(self.bottom_frame, text="Load Image", command=self.load_image, state=tk.DISABLED, height=2, font=("Arial", 12, "bold"))
        self.btn_load.pack(fill=tk.X)
        
    def log(self, msg):
        self.result_text.insert(tk.END, msg + "\n")
        self.result_text.see(tk.END)
        
    def load_pipeline(self):
        try:
            self.pipeline = InferencePipeline()
            self.pipeline_ready = True
            self.root.after(0, lambda: self.btn_load.config(state=tk.NORMAL))
            self.root.after(0, lambda: self.log("\n✅ Pipeline Ready! Load an image to test."))
        except Exception as e:
            self.root.after(0, lambda: self.log(f"\n❌ Error loading pipeline: {e}"))

    def load_image(self):
        file_path = filedialog.askopenfilename(filetypes=[("Images", "*.jpg *.jpeg *.png")])
        if not file_path:
            return
            
        # Display Image
        image = Image.open(file_path)
        
        # Resize for display (keeping aspect ratio)
        display_size = (600, 500)
        image.thumbnail(display_size, Image.LANCZOS)
        
        self.photo = ImageTk.PhotoImage(image)
        self.img_label.config(image=self.photo, text="")
        
        # Clear previous result
        self.result_text.delete(1.0, tk.END)
        self.log(f"Processing: {Path(file_path).name}...")
        
        # Run Inference in Thread
        threading.Thread(target=self.run_inference, args=(file_path,), daemon=True).start()
        
    def run_inference(self, file_path):
        try:
            results = self.pipeline.predict(file_path)
            self.root.after(0, lambda: self.display_results(results))
        except Exception as e:
             self.root.after(0, lambda: self.log(f"Error: {e}"))

    def display_results(self, results):
        self.result_text.delete(1.0, tk.END)
        self.log("=== INFERENCE RESULTS ===\n")
        
        # Final Verdict
        verdict = results.get('final_verdict', 'Unknown')
        self.log(f"Final Verdict: {verdict}\n")
        self.log("-" * 30)
        
        # Stage 0
        s0 = results.get('stage0', {})
        self.log(f"Stage 0 (Filter): {s0.get('class', 'N/A')}")
        self.log(f"  Confidence: {s0.get('confidence', 0):.2%}")
        
        if not s0.get('is_relevant', False) and s0.get('class') != 'diabetic_foot':
             self.log("\n(Stopped at Stage 0)")
             return

        self.log("-" * 20)
        
        # Stage 1
        s1 = results.get('stage1', {})
        self.log(f"Stage 1 (Triage): {'Wound' if s1.get('is_wound') else 'Healthy'}")
        self.log(f"  Prob: {s1.get('probability', 0):.2%}")
        
        if not s1.get('is_wound', False):
             self.log("\n(Stopped at Stage 1)")
             return

        self.log("-" * 20)

        # Stage 2
        s2 = results.get('stage2', {})
        self.log(f"Stage 2 (Type): {s2.get('type', 'N/A').upper()}")
        self.log(f"  Confidence: {s2.get('confidence', 0):.2%}")
        
        self.log("-" * 20)

        # Stage 3
        if 'stage3' in results:
            s3 = results.get('stage3', {})
            self.log(f"Stage 3 (Severity): {s3.get('grade', 'N/A').upper()}")
            self.log(f"  Confidence: {s3.get('confidence', 0):.2%}")
        else:
            self.log("Stage 3: Skipped (Not DFU)")

if __name__ == "__main__":
    root = tk.Tk()
    app = HousepitalApp(root)
    root.mainloop()
