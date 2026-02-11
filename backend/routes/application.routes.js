import express from "express";
import isAuth from "../middlewares/isAuth.js";
import { applyForJob, getJobApplications, getMyApplications, updateApplicationStatus, withdrawApplication, scheduleInterview } from "../controllers/application.controllers.js";

const applicationRouter = express.Router();

applicationRouter.post("/apply", isAuth, applyForJob);
applicationRouter.get("/myapplications", isAuth, getMyApplications);
applicationRouter.get("/job/:jobId", isAuth, getJobApplications); // For recruiter
applicationRouter.put("/status/:applicationId", isAuth, updateApplicationStatus); // For recruiter
applicationRouter.put("/schedule-interview/:applicationId", isAuth, scheduleInterview); // For recruiter
applicationRouter.delete("/withdraw/:applicationId", isAuth, withdrawApplication);

export default applicationRouter;
