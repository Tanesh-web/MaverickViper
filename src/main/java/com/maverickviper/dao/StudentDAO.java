package com.maverickviper.dao;

import com.maverickviper.config.DBConnection;
import com.maverickviper.model.Student;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {

    public Student findByEmail(String email) {
        if (email == null) return null;
        String sql = "SELECT student_id, full_name, email, password_hash, created_at, last_login " +
                     "FROM students WHERE LOWER(email) = LOWER(?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Student findById(int studentId) {
        String sql = "SELECT student_id, full_name, email, password_hash, created_at, last_login " +
                     "FROM students WHERE student_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createStudent(Student student) throws SQLException {
        String sql = "INSERT INTO students (full_name, email, password_hash) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, student.getFullName().trim());
            ps.setString(2, student.getEmail().trim().toLowerCase());
            ps.setString(3, student.getPasswordHash());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        student.setStudentId(keys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public void updateLastLogin(int studentId) {
        String sql = "UPDATE students SET last_login = CURRENT_TIMESTAMP WHERE student_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int countStudents() {
        String sql = "SELECT COUNT(*) FROM students";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Student> getAllStudentsWithStats() {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT s.student_id, s.full_name, s.email, s.password_hash, s.created_at, s.last_login, " +
                     "COUNT(ta.attempt_id) AS tests_count, " +
                     "COALESCE(AVG(CASE WHEN ta.status = 'COMPLETED' THEN ta.accuracy ELSE NULL END), 0) AS avg_acc " +
                     "FROM students s " +
                     "LEFT JOIN test_attempts ta ON s.student_id = ta.student_id " +
                     "GROUP BY s.student_id, s.full_name, s.email, s.password_hash, s.created_at, s.last_login " +
                     "ORDER BY s.student_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Student s = mapRow(rs);
                s.setTestsAttempted(rs.getInt("tests_count"));
                s.setOverallAccuracy(rs.getDouble("avg_acc"));
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Student> searchStudents(String query) {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT s.student_id, s.full_name, s.email, s.password_hash, s.created_at, s.last_login, " +
                     "COUNT(ta.attempt_id) AS tests_count, " +
                     "COALESCE(AVG(CASE WHEN ta.status = 'COMPLETED' THEN ta.accuracy ELSE NULL END), 0) AS avg_acc " +
                     "FROM students s " +
                     "LEFT JOIN test_attempts ta ON s.student_id = ta.student_id " +
                     "WHERE LOWER(s.full_name) LIKE ? OR LOWER(s.email) LIKE ? " +
                     "GROUP BY s.student_id, s.full_name, s.email, s.password_hash, s.created_at, s.last_login " +
                     "ORDER BY s.student_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            String pattern = "%" + (query == null ? "" : query.trim().toLowerCase()) + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Student s = mapRow(rs);
                    s.setTestsAttempted(rs.getInt("tests_count"));
                    s.setOverallAccuracy(rs.getDouble("avg_acc"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Student mapRow(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setStudentId(rs.getInt("student_id"));
        s.setFullName(rs.getString("full_name"));
        s.setEmail(rs.getString("email"));
        s.setPasswordHash(rs.getString("password_hash"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setLastLogin(rs.getTimestamp("last_login"));
        return s;
    }
}
