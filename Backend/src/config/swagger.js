
const swaggerJsdoc = require("swagger-jsdoc");
const swaggerUi = require("swagger-ui-express");

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Housepital AI Backend API",
      version: "1.0.0",
      description: "API documentation for the Housepital AI Backend services, including Auth, User, Booking, and AI integration.",
    },
    servers: [
      {
        url: "http://localhost:3500",
        description: "Development Server",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  // Paths to files containing OpenAPI definitions
  apis: ["./src/routes/*.js", "./src/models/*.js"], 
};

const swaggerSpec = swaggerJsdoc(options);

const swaggerDocs = (app, port) => {
  // Swagger Page
  app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

  // Docs in JSON format
  app.get("/api-docs.json", (req, res) => {
    res.setHeader("Content-Type", "application/json");
    res.send(swaggerSpec);
  });

  console.log(
    `📄 Version 1 Docs are available at http://localhost:${port}/api-docs`
  );
};

module.exports = swaggerDocs;
