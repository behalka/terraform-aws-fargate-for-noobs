const express = require("express");
const os = require("os");
const Knex = require("knex");

const hostname = os.hostname();
const app = express();

/**
 * This setup will only run on AWS (in an instance under the proper security group)
 */
const knex = Knex({
  client: "pg",
  connection: {
    // this needs to be replaced :)
    host: "foo-db-identifier.czitytzpwfs1.eu-central-1.rds.amazonaws.com",
    port: 5432,
    // this just copies whatever is in the main.tf resource
    user: "postgres",
    password: "secretaf",
    database: "foo_db"
  },
  debug: true
});

app.listen(3000, () =>
  console.log(`Example app listening on port 3000! Host: ${hostname}`)
);

app.get("/", async (req, res) => res.json({ hostname }));

app.get("/db", async (req, res) => {
  const count = await knex.raw("SELECT 1+1 as result");
  res.json(count.rows[0]);
});

app.get("/health-check", async (req, res) =>
  res.json({ message: "I am healthy 💊" })
);
