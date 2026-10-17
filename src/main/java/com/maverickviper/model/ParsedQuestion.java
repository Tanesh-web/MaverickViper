package com.maverickviper.model;

public class ParsedQuestion {
    private int tempId;
    private int weekNumber = 0;
    private String category = "WEEKWISE";
    private String questionText = "";
    private String optionA = "";
    private String optionB = "";
    private String optionC = "";
    private String optionD = "";
    private String correctOption = "";
    private String explanation = "";
    private boolean valid;
    private boolean duplicate;
    private String validationError = "";

    public ParsedQuestion() {}

    public int getTempId() {
        return tempId;
    }

    public void setTempId(int tempId) {
        this.tempId = tempId;
    }

    public int getWeekNumber() {
        return weekNumber;
    }

    public void setWeekNumber(int weekNumber) {
        this.weekNumber = weekNumber;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public String getOptionA() {
        return optionA;
    }

    public void setOptionA(String optionA) {
        this.optionA = optionA;
    }

    public String getOptionB() {
        return optionB;
    }

    public void setOptionB(String optionB) {
        this.optionB = optionB;
    }

    public String getOptionC() {
        return optionC;
    }

    public void setOptionC(String optionC) {
        this.optionC = optionC;
    }

    public String getOptionD() {
        return optionD;
    }

    public void setOptionD(String optionD) {
        this.optionD = optionD;
    }

    public String getCorrectOption() {
        return correctOption;
    }

    public void setCorrectOption(String correctOption) {
        this.correctOption = (correctOption == null) ? "" : correctOption.trim().toUpperCase();
    }

    public String getExplanation() {
        return explanation;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public boolean isValid() {
        return valid;
    }

    public void setValid(boolean valid) {
        this.valid = valid;
    }

    public boolean isDuplicate() {
        return duplicate;
    }

    public void setDuplicate(boolean duplicate) {
        this.duplicate = duplicate;
    }

    public String getValidationError() {
        return validationError;
    }

    public void setValidationError(String validationError) {
        this.validationError = validationError;
    }

    public void validate() {
        if (questionText == null || questionText.trim().isEmpty()) {
            valid = false;
            validationError = "Missing question text";
            return;
        }
        if (optionA == null || optionA.trim().isEmpty() ||
            optionB == null || optionB.trim().isEmpty() ||
            optionC == null || optionC.trim().isEmpty() ||
            optionD == null || optionD.trim().isEmpty()) {
            valid = false;
            validationError = "Missing one or more options (A, B, C, D required)";
            return;
        }
        if (correctOption == null || !correctOption.matches("^[ABCD]$")) {
            valid = false;
            validationError = "Invalid or missing correct answer (must be A, B, C, or D)";
            return;
        }
        valid = true;
        validationError = "";
    }
}
