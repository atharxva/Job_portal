import Job from "../models/job.model.js";
import Application from "../models/application.model.js";
import User from "../models/user.model.js";

export const createJob = async (req, res) => {
    try {
        const { title, description, company, location, salary, requirements, contactName, contactEmail } = req.body;

        // Ensure only recruiters can create jobs
        const user = await User.findById(req.userId);
        if (!user || user.role !== "recruiter") {
            return res.status(403).json({ message: "Only recruiters can post jobs" });
        }

        const newJob = await Job.create({
            title,
            description,
            company,
            location,
            salary,
            requirements,
            contactName,
            contactEmail,
            postedBy: req.userId
        });

        return res.status(201).json(newJob);
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error creating job" });
    }
};

export const getAllJobs = async (req, res) => {
    try {
        const jobs = await Job.find().populate("postedBy", "firstName lastName profileImage headline").sort({ createdAt: -1 });

        // Add isApplied flag for each job
        const jobsWithAppliedStatus = jobs.map(job => {
            const jobObj = job.toObject();
            jobObj.isApplied = job.applicants.includes(req.userId);
            return jobObj;
        });

        return res.status(200).json(jobsWithAppliedStatus);
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error fetching jobs" });
    }
};

export const getMyJobs = async (req, res) => {
    try {
        const jobs = await Job.find({ postedBy: req.userId }).sort({ createdAt: -1 });
        return res.status(200).json(jobs);
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error fetching my jobs" });
    }
};

export const updateJob = async (req, res) => {
    try {
        const { id } = req.params;
        const { title, description, company, location, salary, requirements, contactName, contactEmail } = req.body;

        const job = await Job.findById(id);
        if (!job) {
            return res.status(404).json({ message: "Job not found" });
        }

        // Check if the user is the owner of the job
        if (job.postedBy.toString() !== req.userId) {
            return res.status(403).json({ message: "Unauthorized to update this job" });
        }

        job.title = title || job.title;
        job.description = description || job.description;
        job.company = company || job.company;
        job.location = location || job.location;
        job.salary = salary || job.salary;
        job.requirements = requirements || job.requirements;
        job.contactName = contactName || job.contactName;
        job.contactEmail = contactEmail || job.contactEmail;

        const updatedJob = await job.save();
        return res.status(200).json(updatedJob);
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error updating job" });
    }
};

export const deleteJob = async (req, res) => {
    try {
        const { id } = req.params;

        const job = await Job.findById(id);
        if (!job) {
            return res.status(404).json({ message: "Job not found" });
        }

        // Check ownership
        if (job.postedBy.toString() !== req.userId) {
            return res.status(403).json({ message: "Unauthorized to delete this job" });
        }

        await Job.findByIdAndDelete(id);
        // Also clean up applications for this job
        await Application.deleteMany({ job: id });

        return res.status(200).json({ message: "Job deleted successfully" });
    } catch (error) {
        console.log(error);
        return res.status(500).json({ message: "Error deleting job" });
    }
};

export const getRecruiterStats = async (req, res) => {
    console.log(`[Stats Request] User: ${req.userId}`);
    try {
        const recruiterId = req.userId;

        // Ensure only recruiters can access analytics
        const user = await User.findById(recruiterId);
        if (!user || user.role !== "recruiter") {
            console.log(`[Stats Denied] User is not a recruiter. Role: ${user?.role}`);
            return res.status(403).json({ message: "Only recruiters can access hiring analytics" });
        }

        // 1. Total Jobs Posted by this recruiter
        const totalJobs = await Job.countDocuments({ postedBy: recruiterId }) || 0;

        // 2. Total Applications received for all jobs by this recruiter
        const myJobs = await Job.find({ postedBy: recruiterId }).select('_id title applicants') || [];
        const jobIds = myJobs.map(job => job._id);

        const applications = await Application.find({ job: { $in: jobIds } }) || [];
        const totalApplications = applications.length;

        // 3. Status Breakdown
        const stats = {
            applied: 0,
            interview: 0,
            hired: 0,
            rejected: 0
        };

        applications.forEach(app => {
            if (app.status && stats[app.status] !== undefined) {
                stats[app.status]++;
            }
        });

        // 4. Hire Rate
        const hireRate = totalApplications > 0
            ? ((stats.hired / totalApplications) * 100).toFixed(1)
            : "0.0";

        // 5. Job Performance (Top 5 jobs by application count)
        const jobStats = [...myJobs]
            .sort((a, b) => (b.applicants?.length || 0) - (a.applicants?.length || 0))
            .slice(0, 5);

        console.log(`[Stats Success] Jobs: ${totalJobs}, Apps: ${totalApplications}`);

        return res.status(200).json({
            totalJobs,
            totalApplications,
            stats,
            hireRate,
            jobStats: jobStats.map(j => ({
                title: j.title || "Untitled Job",
                count: j.applicants?.length || 0
            }))
        });
    } catch (error) {
        console.error("Error in getRecruiterStats:", error);
        return res.status(500).json({ message: "Internal server error fetching stats", error: error.message });
    }
};

export const toggleFeaturedJob = async (req, res) => {
    try {
        const jobId = req.params.id;
        const recruiterId = req.userId;

        const job = await Job.findById(jobId);
        if (!job) {
            return res.status(404).json({ message: "Job not found" });
        }

        if (job.postedBy.toString() !== recruiterId) {
            return res.status(403).json({ message: "You can only feature your own jobs" });
        }

        job.isFeatured = !job.isFeatured;
        await job.save();

        return res.status(200).json({
            message: job.isFeatured ? "Job featured successfully" : "Job unfeatured successfully",
            isFeatured: job.isFeatured
        });
    } catch (error) {
        console.error("Error toggling featured job:", error);
        return res.status(500).json({ message: "Internal server error" });
    }
};
