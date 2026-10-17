package com.maverickviper.dao;

import com.maverickviper.config.DBConnection;
import com.maverickviper.model.Question;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class QuestionDAO {

    public List<Question> getAllQuestionsForReading(int courseId) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT question_id, course_id, week_id, week_number, question_text, " +
                     "option_a, option_b, option_c, option_d, correct_option, category, explanation, created_at, updated_at " +
                     "FROM questions WHERE course_id = ? ORDER BY week_number ASC, question_id ASC";
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

    public List<Question> getQuestionsByWeek(int courseId, int weekNumber) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT question_id, course_id, week_id, week_number, question_text, " +
                     "option_a, option_b, option_c, option_d, correct_option, category, explanation, created_at, updated_at " +
                     "FROM questions WHERE course_id = ? AND week_number = ? ORDER BY question_id ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setInt(2, weekNumber);
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

    public List<Question> getQuestionsByCategory(int courseId, String category) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT question_id, course_id, week_id, week_number, question_text, " +
                     "option_a, option_b, option_c, option_d, correct_option, category, explanation, created_at, updated_at " +
                     "FROM questions WHERE course_id = ? AND category = ? ORDER BY week_number ASC, question_id ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setString(2, category);
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

    public Question getQuestionById(int questionId) {
        String sql = "SELECT question_id, course_id, week_id, week_number, question_text, " +
                     "option_a, option_b, option_c, option_d, correct_option, category, explanation, created_at, updated_at " +
                     "FROM questions WHERE question_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, questionId);
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

    public boolean addQuestion(Question q) {
        String sql = "INSERT INTO questions (course_id, week_id, week_number, question_text, " +
                     "option_a, option_b, option_c, option_d, correct_option, category, explanation) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, q.getCourseId());
            if (q.getWeekId() != null) {
                ps.setInt(2, q.getWeekId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setInt(3, q.getWeekNumber());
            ps.setString(4, q.getQuestionText().trim());
            ps.setString(5, q.getOptionA().trim());
            ps.setString(6, q.getOptionB().trim());
            ps.setString(7, q.getOptionC().trim());
            ps.setString(8, q.getOptionD().trim());
            ps.setString(9, q.getCorrectOption().trim().toUpperCase());
            ps.setString(10, (q.getCategory() == null || q.getCategory().isEmpty()) ? "WEEKWISE" : q.getCategory());
            ps.setString(11, q.getExplanation() == null ? null : q.getExplanation().trim());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        q.setQuestionId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateQuestion(Question q) {
        String sql = "UPDATE questions SET week_id = ?, week_number = ?, question_text = ?, " +
                     "option_a = ?, option_b = ?, option_c = ?, option_d = ?, correct_option = ?, " +
                     "category = ?, explanation = ? WHERE question_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (q.getWeekId() != null) {
                ps.setInt(1, q.getWeekId());
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setInt(2, q.getWeekNumber());
            ps.setString(3, q.getQuestionText().trim());
            ps.setString(4, q.getOptionA().trim());
            ps.setString(5, q.getOptionB().trim());
            ps.setString(6, q.getOptionC().trim());
            ps.setString(7, q.getOptionD().trim());
            ps.setString(8, q.getCorrectOption().trim().toUpperCase());
            ps.setString(9, q.getCategory());
            ps.setString(10, q.getExplanation());
            ps.setInt(11, q.getQuestionId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteQuestion(int questionId) {
        String sql = "DELETE FROM questions WHERE question_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int countQuestions(int courseId) {
        String sql = "SELECT COUNT(*) FROM questions WHERE course_id = ?";
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

    public List<Question> searchQuestions(int courseId, String keyword, Integer weekNumber, String category) {
        List<Question> list = new ArrayList<>();
        StringBuilder sb = new StringBuilder("SELECT question_id, course_id, week_id, week_number, question_text, ")
                .append("option_a, option_b, option_c, option_d, correct_option, category, explanation, created_at, updated_at ")
                .append("FROM questions WHERE course_id = ?");

        List<Object> params = new ArrayList<>();
        params.add(courseId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sb.append(" AND (LOWER(question_text) LIKE ? OR LOWER(option_a) LIKE ? OR LOWER(option_b) LIKE ? OR LOWER(option_c) LIKE ? OR LOWER(option_d) LIKE ?)");
            String k = "%" + keyword.trim().toLowerCase() + "%";
            for (int i = 0; i < 5; i++) params.add(k);
        }

        if (weekNumber != null && weekNumber >= 0) {
            sb.append(" AND week_number = ?");
            params.add(weekNumber);
        }

        if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("ALL")) {
            sb.append(" AND category = ?");
            params.add(category.trim());
        }

        sb.append(" ORDER BY week_number ASC, question_id ASC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sb.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
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

    public List<Question> getQuestionsForShuffle(int courseId, int limit) {
        List<Question> all = getAllQuestionsForReading(courseId);
        if (all.isEmpty()) return all;
        Collections.shuffle(all);
        if (limit > 0 && limit < all.size()) {
            return new ArrayList<>(all.subList(0, limit));
        }
        return all;
    }

    public int batchInsertQuestions(int courseId, List<Question> questions) throws SQLException {
        if (questions == null || questions.isEmpty()) {
            return 0;
        }

        String sql = "INSERT INTO questions (course_id, week_id, week_number, question_text, " +
                     "option_a, option_b, option_c, option_d, correct_option, category, explanation) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) throw new SQLException("Database connection failed");
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                for (Question q : questions) {
                    ps.setInt(1, courseId);
                    if (q.getWeekId() != null) {
                        ps.setInt(2, q.getWeekId());
                    } else {
                        ps.setNull(2, java.sql.Types.INTEGER);
                    }
                    ps.setInt(3, q.getWeekNumber());
                    ps.setString(4, q.getQuestionText().trim());
                    ps.setString(5, q.getOptionA().trim());
                    ps.setString(6, q.getOptionB().trim());
                    ps.setString(7, q.getOptionC().trim());
                    ps.setString(8, q.getOptionD().trim());
                    ps.setString(9, q.getCorrectOption().trim().toUpperCase());
                    ps.setString(10, (q.getCategory() == null || q.getCategory().isEmpty()) ? "WEEKWISE" : q.getCategory());
                    ps.setString(11, q.getExplanation() == null ? null : q.getExplanation().trim());
                    ps.addBatch();
                }
                int[] results = ps.executeBatch();
                con.commit();
                return results.length;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    private Question mapRow(ResultSet rs) throws SQLException {
        Question q = new Question();
        q.setQuestionId(rs.getInt("question_id"));
        q.setCourseId(rs.getInt("course_id"));
        int wid = rs.getInt("week_id");
        if (!rs.wasNull()) {
            q.setWeekId(wid);
        }
        q.setWeekNumber(rs.getInt("week_number"));
        q.setQuestionText(rs.getString("question_text"));
        q.setOptionA(rs.getString("option_a"));
        q.setOptionB(rs.getString("option_b"));
        q.setOptionC(rs.getString("option_c"));
        q.setOptionD(rs.getString("option_d"));
        q.setCorrectOption(rs.getString("correct_option"));
        q.setCategory(rs.getString("category"));
        q.setExplanation(rs.getString("explanation"));
        q.setCreatedAt(rs.getTimestamp("created_at"));
        q.setUpdatedAt(rs.getTimestamp("updated_at"));
        return q;
    }
}
