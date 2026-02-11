import Application from "../models/application.model.js";
import Job from "../models/job.model.js";

export const applyForJob = async (req, res) => {
    try {
        const { jobId } = req.body;

        // Check if already applied
        const existingApplication = await Application.findOne({ job: jobId, applicant: req.userId });
        if (existingApplication) {
            return res.status(400).json({ message: "You have already applied for this job" });
        }

        const application = await Application.create({
            job: jobId,
            applicant: req.userId,
            status: "applied"
        });

        // Add applicant to Job model
        await Job.findByIdAndUpdate(jobId, { $push: { applicants: req.userId } });

        return res.status(201).json({ message: "Applied successfully", application });
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error applying for job" });
    }
};

export const getMyApplications = async (req, res) => {
    try {
        const applications = await Application.find({ applicant: req.userId })
            .populate("job")
            .sort({ createdAt: -1 });
        return res.status(200).json(applications);
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error fetching applications" });
    }
};

export const getJobApplications = async (req, res) => {
    try {
        const { jobId } = req.params;
        const applications = await Application.find({ job: jobId })
            .populate("applicant", "firstName lastName profileImage headline email")
            .sort({ createdAt: -1 });
        return res.status(200).json(applications);
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error fetching job applications" });
    }
};

export const updateApplicationStatus = async (req, res) => {
    try {
        const { applicationId } = req.params;
        const { status } = req.body;

        const application = await Application.findByIdAndUpdate(
            applicationId,
            { status },
            { new: true }
        );

        if (!application) return res.status(404).json({ message: "Application not found" });

        return res.status(200).json({ message: "Status updated", application });
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error updating status" });
    }
};

export const withdrawApplication = async (req, res) => {
    try {
        const { applicationId } = req.params;

        const application = await Application.findById(applicationId);
        if (!application) {
            return res.status(404).json({ message: "Application not found" });
        }

        // Check ownership
        if (application.applicant.toString() !== req.userId) {
            return res.status(403).json({ message: "Unauthorized to withdraw this application" });
        }

        const jobId = application.job;
        await Application.findByIdAndDelete(applicationId);

        // Remove applicant from Job model
        await Job.findByIdAndUpdate(jobId, { $pull: { applicants: req.userId } });

        return res.status(200).json({ message: "Application withdrawn successfully" });
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error withdrawing application" });
    }
};

export const scheduleInterview = async (req, res) => {
    try {
        const { applicationId } = req.params;
        const { interviewDate, interviewLocation } = req.body;

        const application = await Application.findById(applicationId).populate('job');
        if (!application) {
            return res.status(404).json({ message: "Application not found" });
        }

        // Only the recruiter who posted the job can schedule an interview
        if (application.job.postedBy.toString() !== req.userId) {
            return res.status(403).json({ message: "Unauthorized to schedule interview for this job" });
        }

        application.interviewDate = interviewDate;
        application.interviewLocation = interviewLocation;
        application.status = "interview"; // Automatically move to interview status

        await application.save();

        return res.status(200).json({
            message: "Interview scheduled successfully",
            application
        });
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error scheduling interview" });
    }
};
