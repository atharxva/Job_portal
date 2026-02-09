import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    firstName: {
        type: String,
        required: true
    },
    lastName: {
        type: String,
        required: true
    },
    userName: {
        type: String,
        required: true,
        unique: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true,
    },
    profileImage: {
        type: String,
        default: ""
    },
    coverImage: {
        type: String,
        default: ""
    },
    headline: {
        type: String,
        default: ""
    },
    skills: [{ type: String }],
    education: [
        {
            college: { type: String },
            degree: { type: String },
            fieldOfStudy: { type: String }

        }
    ],
    location: {
        type: String,
        default: "India"
    },
    gender: {
        type: String,
        enum: ["male", "female", "other"]
    },
    experience: [
        {
            title: { type: String },
            company: { type: String },
            description: { type: String }
        }
    ],
    role: {
        type: String,
        enum: ["recruiter", "candidate"],
        default: "candidate"
    },
    about: {
        type: String,
        default: ""
    },
    connection: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User"
        }
    ]

}, { timestamps: true })

const User = mongoose.model("User", userSchema)
export default User