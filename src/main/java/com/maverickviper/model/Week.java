package com.maverickviper.model;

import java.sql.Timestamp;

public class Week {
    private int weekId;
    private int courseId;
    private int weekNumber;
    private String weekName;
    private int questionCount;
    private Timestamp createdAt;

    public Week() {}

    public Week(int weekId, int courseId, int weekNumber, String weekName, Timestamp createdAt) {
        this.weekId = weekId;
        this.courseId = courseId;
        this.weekNumber = weekNumber;
        this.weekName = weekName;
        this.createdAt = createdAt;
    }

    public int getWeekId() {
        return weekId;
    }

    public void setWeekId(int weekId) {
        this.weekId = weekId;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public int getWeekNumber() {
        return weekNumber;
    }

    public void setWeekNumber(int weekNumber) {
        this.weekNumber = weekNumber;
    }

    public String getWeekName() {
        return weekName;
    }

    public void setWeekName(String weekName) {
        this.weekName = weekName;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
