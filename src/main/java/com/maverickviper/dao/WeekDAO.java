package com.maverickviper.dao;

import com.maverickviper.config.DBConnection;
import com.maverickviper.model.Week;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class WeekDAO {

    public List<Week> getAllWeeks(int courseId) {
        List<Week> weeks = new ArrayList<>();
        String sql = "SELECT w.week_id, w.course_id, w.week_number, w.week_name, w.created_at, " +
                     "COUNT(q.question_id) AS question_count " +
                     "FROM weeks w " +
                     "LEFT JOIN questions q ON (q.week_id = w.week_id OR (q.course_id = w.course_id AND q.week_number = w.week_number)) " +
                     "WHERE w.course_id = ? " +
                     "GROUP BY w.week_id, w.course_id, w.week_number, w.week_name, w.created_at " +
                     "ORDER BY w.week_number ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Week week = new Week();
                    week.setWeekId(rs.getInt("week_id"));
                    week.setCourseId(rs.getInt("course_id"));
                    week.setWeekNumber(rs.getInt("week_number"));
                    week.setWeekName(rs.getString("week_name"));
                    week.setCreatedAt(rs.getTimestamp("created_at"));
                    week.setQuestionCount(rs.getInt("question_count"));
                    weeks.add(week);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return weeks;
    }

    public Week getWeekById(int weekId) {
        String sql = "SELECT week_id, course_id, week_number, week_name, created_at FROM weeks WHERE week_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, weekId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Week week = new Week();
                    week.setWeekId(rs.getInt("week_id"));
                    week.setCourseId(rs.getInt("course_id"));
                    week.setWeekNumber(rs.getInt("week_number"));
                    week.setWeekName(rs.getString("week_name"));
                    week.setCreatedAt(rs.getTimestamp("created_at"));
                    return week;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Week getWeekByNumber(int courseId, int weekNumber) {
        String sql = "SELECT week_id, course_id, week_number, week_name, created_at FROM weeks WHERE course_id = ? AND week_number = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setInt(2, weekNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Week week = new Week();
                    week.setWeekId(rs.getInt("week_id"));
                    week.setCourseId(rs.getInt("course_id"));
                    week.setWeekNumber(rs.getInt("week_number"));
                    week.setWeekName(rs.getString("week_name"));
                    week.setCreatedAt(rs.getTimestamp("created_at"));
                    return week;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addWeek(Week week) {
        String sql = "INSERT INTO weeks (course_id, week_number, week_name) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, week.getCourseId());
            ps.setInt(2, week.getWeekNumber());
            ps.setString(3, week.getWeekName().trim());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        week.setWeekId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateWeek(Week week) {
        String sql = "UPDATE weeks SET week_number = ?, week_name = ? WHERE week_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, week.getWeekNumber());
            ps.setString(2, week.getWeekName().trim());
            ps.setInt(3, week.getWeekId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteWeek(int weekId) {
        // Safe delete: first unlink questions or prevent if questions exist
        String countSql = "SELECT COUNT(*) FROM questions WHERE week_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement checkPs = con.prepareStatement(countSql)) {
            checkPs.setInt(1, weekId);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return false; // Cannot delete week with existing questions
                }
            }

            String deleteSql = "DELETE FROM weeks WHERE week_id = ?";
            try (PreparedStatement delPs = con.prepareStatement(deleteSql)) {
                delPs.setInt(1, weekId);
                return delPs.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int countWeeks(int courseId) {
        String sql = "SELECT COUNT(*) FROM weeks WHERE course_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
