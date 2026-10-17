package com.maverickviper.model;

import java.sql.Timestamp;

public class Student {
    private int studentId;
    private String fullName;
    private String email;
    private String passwordHash;
    private Timestamp createdAt;
    private Timestamp lastLogin;
    private int testsAttempted;
    private double overallAccuracy;

    public Student() {}

    public Student(int studentId, String fullName, String email, String passwordHash, Timestamp createdAt, Timestamp lastLogin) {
        this.studentId = studentId;
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.createdAt = createdAt;
        this.lastLogin = lastLogin;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(Timestamp lastLogin) {
        this.lastLogin = lastLogin;
    }

    public int getTestsAttempted() {
        return testsAttempted;
    }

    public void setTestsAttempted(int testsAttempted) {
        this.testsAttempted = testsAttempted;
    }

    public double getOverallAccuracy() {
        return overallAccuracy;
    }

    public void setOverallAccuracy(double overallAccuracy) {
        this.overallAccuracy = overallAccuracy;
    }
}
