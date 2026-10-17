package com.maverickviper.model;

import java.sql.Timestamp;

public class TestModel {
    private int testId;
    private int courseId;
    private String testName;
    private String testType; // ALL_MCQ, WEEK_WISE, SHUFFLE
    private Integer weekId;
    private int durationMinutes;
    private double marksPerQuestion;
    private double negativeMarks;
    private boolean shuffleOptions;
    private int totalQuestions;
    private Timestamp createdAt;

    public TestModel() {
        this.durationMinutes = 30;
        this.marksPerQuestion = 1.0;
        this.negativeMarks = 0.0;
        this.shuffleOptions = false;
    }

    public TestModel(int testId, int courseId, String testName, String testType, Integer weekId,
                     int durationMinutes, double marksPerQuestion, double negativeMarks,
                     boolean shuffleOptions, int totalQuestions, Timestamp createdAt) {
        this.testId = testId;
        this.courseId = courseId;
        this.testName = testName;
        this.testType = testType;
        this.weekId = weekId;
        this.durationMinutes = durationMinutes;
        this.marksPerQuestion = marksPerQuestion;
        this.negativeMarks = negativeMarks;
        this.shuffleOptions = shuffleOptions;
        this.totalQuestions = totalQuestions;
        this.createdAt = createdAt;
    }

    public int getTestId() {
        return testId;
    }

    public void setTestId(int testId) {
        this.testId = testId;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public String getTestName() {
        return testName;
    }

    public void setTestName(String testName) {
        this.testName = testName;
    }

    public String getTestType() {
        return testType;
    }

    public void setTestType(String testType) {
        this.testType = testType;
    }

    public Integer getWeekId() {
        return weekId;
    }

    public void setWeekId(Integer weekId) {
        this.weekId = weekId;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(int durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public double getMarksPerQuestion() {
        return marksPerQuestion;
    }

    public void setMarksPerQuestion(double marksPerQuestion) {
        this.marksPerQuestion = marksPerQuestion;
    }

    public double getNegativeMarks() {
        return negativeMarks;
    }

    public void setNegativeMarks(double negativeMarks) {
        this.negativeMarks = negativeMarks;
    }

    public boolean isShuffleOptions() {
        return shuffleOptions;
    }

    public void setShuffleOptions(boolean shuffleOptions) {
        this.shuffleOptions = shuffleOptions;
    }

    public int getTotalQuestions() {
        return totalQuestions;
    }

    public void setTotalQuestions(int totalQuestions) {
        this.totalQuestions = totalQuestions;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
