package com.maverickviper.model;

import java.sql.Timestamp;

public class StudentAnswer {
    private int answerId;
    private int attemptId;
    private int questionId;
    private String selectedOption;
    private String correctOptionSnapshot;
    private boolean isCorrect;
    private String questionTextSnapshot;
    private String optionASnapshot;
    private String optionBSnapshot;
    private String optionCSnapshot;
    private String optionDSnapshot;
    private String explanationSnapshot;
    private Timestamp answeredAt;

    public StudentAnswer() {}

    public int getAnswerId() {
        return answerId;
    }

    public void setAnswerId(int answerId) {
        this.answerId = answerId;
    }

    public int getAttemptId() {
        return attemptId;
    }

    public void setAttemptId(int attemptId) {
        this.attemptId = attemptId;
    }

    public int getQuestionId() {
        return questionId;
    }

    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }

    public String getSelectedOption() {
        return selectedOption;
    }

    public void setSelectedOption(String selectedOption) {
        this.selectedOption = selectedOption;
    }

    public String getCorrectOptionSnapshot() {
        return correctOptionSnapshot;
    }

    public void setCorrectOptionSnapshot(String correctOptionSnapshot) {
        this.correctOptionSnapshot = correctOptionSnapshot;
    }

    public boolean isCorrect() {
        return isCorrect;
    }

    public void setCorrect(boolean correct) {
        isCorrect = correct;
    }

    public String getQuestionTextSnapshot() {
        return questionTextSnapshot;
    }

    public void setQuestionTextSnapshot(String questionTextSnapshot) {
        this.questionTextSnapshot = questionTextSnapshot;
    }

    public String getOptionASnapshot() {
        return optionASnapshot;
    }

    public void setOptionASnapshot(String optionASnapshot) {
        this.optionASnapshot = optionASnapshot;
    }

    public String getOptionBSnapshot() {
        return optionBSnapshot;
    }

    public void setOptionBSnapshot(String optionBSnapshot) {
        this.optionBSnapshot = optionBSnapshot;
    }

    public String getOptionCSnapshot() {
        return optionCSnapshot;
    }

    public void setOptionCSnapshot(String optionCSnapshot) {
        this.optionCSnapshot = optionCSnapshot;
    }

    public String getOptionDSnapshot() {
        return optionDSnapshot;
    }

    public void setOptionDSnapshot(String optionDSnapshot) {
        this.optionDSnapshot = optionDSnapshot;
    }

    public String getExplanationSnapshot() {
        return explanationSnapshot;
    }

    public void setExplanationSnapshot(String explanationSnapshot) {
        this.explanationSnapshot = explanationSnapshot;
    }

    public Timestamp getAnsweredAt() {
        return answeredAt;
    }

    public void setAnsweredAt(Timestamp answeredAt) {
        this.answeredAt = answeredAt;
    }
}
