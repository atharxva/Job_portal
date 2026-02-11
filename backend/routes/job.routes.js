import express from "express";
import isAuth from "../middlewares/isAuth.js";
import { createJob, deleteJob, getAllJobs, getMyJobs, getRecruiterStats, updateJob } from "../controllers/job.controllers.js";

const jobRouter = express.Router();

jobRouter.post("/create", isAuth, createJob);
jobRouter.get("/all", isAuth, getAllJobs);
jobRouter.get("/myjobs", isAuth, getMyJobs);
jobRouter.get("/stats", isAuth, getRecruiterStats);
jobRouter.put("/update/:id", isAuth, updateJob);
jobRouter.delete("/delete/:id", isAuth, deleteJob);

export default jobRouter;
