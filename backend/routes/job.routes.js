import express from "express";
import isAuth from "../middlewares/isAuth.js";
import { createJob, getAllJobs, getMyJobs } from "../controllers/job.controllers.js";

const jobRouter = express.Router();

jobRouter.post("/create", isAuth, createJob);
jobRouter.get("/all", isAuth, getAllJobs);
jobRouter.get("/myjobs", isAuth, getMyJobs);

export default jobRouter;
