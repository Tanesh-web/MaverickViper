package com.maverickviper.dao;

import com.maverickviper.config.DBConnection;
import com.maverickviper.model.LoginActivity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class LoginActivityDAO {

    public int recordLogin(int studentId) {
        String sql = "INSERT INTO login_history (student_id, login_time, status) VALUES (?, CURRENT_TIMESTAMP, 'SUCCESS')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, studentId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void recordLogout(int studentId, int loginId) {
        String sql;
        if (loginId > 0) {
            sql = "UPDATE login_history SET logout_time = CURRENT_TIMESTAMP WHERE login_id = ?";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, loginId);
                ps.executeUpdate();
                return;
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        // Fallback: update most recent login record for this student
        sql = "UPDATE login_history SET logout_time = CURRENT_TIMESTAMP WHERE student_id = ? AND logout_time IS NULL ORDER BY login_id DESC LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<LoginActivity> getRecentActivity(int limit) {
        List<LoginActivity> list = new ArrayList<>();
        String sql = "SELECT lh.login_id, lh.student_id, s.full_name, s.email, lh.login_time, lh.logout_time, lh.status " +
                     "FROM login_history lh " +
                     "JOIN students s ON lh.student_id = s.student_id " +
                     "ORDER BY lh.login_id DESC LIMIT ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit <= 0 ? 50 : limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LoginActivity a = new LoginActivity(
                            rs.getInt("login_id"),
                            rs.getInt("student_id"),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getTimestamp("login_time"),
                            rs.getTimestamp("logout_time"),
                            rs.getString("status")
                    );
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LoginActivity> getStudentLoginHistory(int studentId) {
        List<LoginActivity> list = new ArrayList<>();
        String sql = "SELECT lh.login_id, lh.student_id, s.full_name, s.email, lh.login_time, lh.logout_time, lh.status " +
                     "FROM login_history lh " +
                     "JOIN students s ON lh.student_id = s.student_id " +
                     "WHERE lh.student_id = ? " +
                     "ORDER BY lh.login_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LoginActivity a = new LoginActivity(
                            rs.getInt("login_id"),
                            rs.getInt("student_id"),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getTimestamp("login_time"),
                            rs.getTimestamp("logout_time"),
                            rs.getString("status")
                    );
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
