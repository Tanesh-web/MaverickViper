package com.maverickviper.model;

public class Admin {
    private int adminId;
    private String username;
    private String passwordHash;

    public Admin() {}

    public Admin(int adminId, String username, String passwordHash) {
        this.adminId = adminId;
        this.username = username;
        this.passwordHash = passwordHash;
    }

    public int getAdminId() {
        return adminId;
    }

    public void setAdminId(int adminId) {
        this.adminId = adminId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }
}
