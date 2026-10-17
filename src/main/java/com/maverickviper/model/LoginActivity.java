package com.maverickviper.model;

import java.sql.Timestamp;

public class LoginActivity {
    private int loginId;
    private int studentId;
    private String studentName;
    private String studentEmail;
    private Timestamp loginTime;
    private Timestamp logoutTime;
    private String status;

    public LoginActivity() {}

    public LoginActivity(int loginId, int studentId, String studentName, String studentEmail,
                         Timestamp loginTime, Timestamp logoutTime, String status) {
        this.loginId = loginId;
        this.studentId = studentId;
        this.studentName = studentName;
        this.studentEmail = studentEmail;
        this.loginTime = loginTime;
        this.logoutTime = logoutTime;
        this.status = status;
    }

    public int getLoginId() {
        return loginId;
    }

    public void setLoginId(int loginId) {
        this.loginId = loginId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getStudentEmail() {
        return studentEmail;
    }

    public void setStudentEmail(String studentEmail) {
        this.studentEmail = studentEmail;
    }

    public Timestamp getLoginTime() {
        return loginTime;
    }

    public void setLoginTime(Timestamp loginTime) {
        this.loginTime = loginTime;
    }

    public Timestamp getLogoutTime() {
        return logoutTime;
    }

    public void setLogoutTime(Timestamp logoutTime) {
        this.logoutTime = logoutTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
