import Fastify from "fastify";

const app = Fastify();

app.get("/", async () => {
    return {
        status: "API RUNNING"
    };
});

app.listen({
    port: 4000
});