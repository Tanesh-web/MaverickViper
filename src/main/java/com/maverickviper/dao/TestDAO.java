package com.maverickviper.dao;

import com.maverickviper.config.DBConnection;
import com.maverickviper.model.TestModel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class TestDAO {

    public List<TestModel> getAllTests(int courseId) {
        List<TestModel> list = new ArrayList<>();
        String sql = "SELECT test_id, course_id, test_name, test_type, week_id, duration_minutes, " +
                     "marks_per_question, negative_marks, shuffle_options, total_questions, created_at " +
                     "FROM tests WHERE course_id = ? ORDER BY test_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public TestModel getTestById(int testId) {
        String sql = "SELECT test_id, course_id, test_name, test_type, week_id, duration_minutes, " +
                     "marks_per_question, negative_marks, shuffle_options, total_questions, created_at " +
                     "FROM tests WHERE test_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, testId);
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

    public boolean createTest(TestModel test) {
        String sql = "INSERT INTO tests (course_id, test_name, test_type, week_id, duration_minutes, " +
                     "marks_per_question, negative_marks, shuffle_options, total_questions) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, test.getCourseId());
            ps.setString(2, test.getTestName().trim());
            ps.setString(3, test.getTestType());
            if (test.getWeekId() != null) {
                ps.setInt(4, test.getWeekId());
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setInt(5, test.getDurationMinutes());
            ps.setDouble(6, test.getMarksPerQuestion());
            ps.setDouble(7, test.getNegativeMarks());
            ps.setBoolean(8, test.isShuffleOptions());
            ps.setInt(9, test.getTotalQuestions());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        test.setTestId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteTest(int testId) {
        String sql = "DELETE FROM tests WHERE test_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, testId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int countTests(int courseId) {
        String sql = "SELECT COUNT(*) FROM tests WHERE course_id = ?";
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

    private TestModel mapRow(ResultSet rs) throws SQLException {
        TestModel t = new TestModel();
        t.setTestId(rs.getInt("test_id"));
        t.setCourseId(rs.getInt("course_id"));
        t.setTestName(rs.getString("test_name"));
        t.setTestType(rs.getString("test_type"));
        int wid = rs.getInt("week_id");
        if (!rs.wasNull()) {
            t.setWeekId(wid);
        }
        t.setDurationMinutes(rs.getInt("duration_minutes"));
        t.setMarksPerQuestion(rs.getDouble("marks_per_question"));
        t.setNegativeMarks(rs.getDouble("negative_marks"));
        t.setShuffleOptions(rs.getBoolean("shuffle_options"));
        t.setTotalQuestions(rs.getInt("total_questions"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        return t;
    }
}
