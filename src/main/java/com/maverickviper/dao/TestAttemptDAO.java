package com.maverickviper.dao;

import com.maverickviper.config.DBConnection;
import com.maverickviper.model.StudentAnswer;
import com.maverickviper.model.TestAttempt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TestAttemptDAO {

    public boolean createAttempt(TestAttempt attempt) {
        String sql = "INSERT INTO test_attempts (student_id, test_id, test_name, test_type, " +
                     "total_questions, attempted, correct, incorrect, unanswered, score, " +
                     "accuracy, percentage, started_at, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, attempt.getStudentId());
            if (attempt.getTestId() != null) {
                ps.setInt(2, attempt.getTestId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, attempt.getTestName());
            ps.setString(4, attempt.getTestType());
            ps.setInt(5, attempt.getTotalQuestions());
            ps.setInt(6, attempt.getAttempted());
            ps.setInt(7, attempt.getCorrect());
            ps.setInt(8, attempt.getIncorrect());
            ps.setInt(9, attempt.getUnanswered());
            ps.setDouble(10, attempt.getScore());
            ps.setDouble(11, attempt.getAccuracy());
            ps.setDouble(12, attempt.getPercentage());
            ps.setString(13, attempt.getStatus() == null ? "IN_PROGRESS" : attempt.getStatus());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        attempt.setAttemptId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public TestAttempt getAttemptById(int attemptId) {
        String sql = "SELECT attempt_id, student_id, test_id, test_name, test_type, " +
                     "total_questions, attempted, correct, incorrect, unanswered, score, " +
                     "accuracy, percentage, started_at, completed_at, status " +
                     "FROM test_attempts WHERE attempt_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
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

    public boolean updateAttempt(TestAttempt attempt) {
        String sql = "UPDATE test_attempts SET attempted = ?, correct = ?, incorrect = ?, " +
                     "unanswered = ?, score = ?, accuracy = ?, percentage = ?, " +
                     "completed_at = CURRENT_TIMESTAMP, status = ? WHERE attempt_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, attempt.getAttempted());
            ps.setInt(2, attempt.getCorrect());
            ps.setInt(3, attempt.getIncorrect());
            ps.setInt(4, attempt.getUnanswered());
            ps.setDouble(5, attempt.getScore());
            ps.setDouble(6, attempt.getAccuracy());
            ps.setDouble(7, attempt.getPercentage());
            ps.setString(8, attempt.getStatus() == null ? "COMPLETED" : attempt.getStatus());
            ps.setInt(9, attempt.getAttemptId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<TestAttempt> getAttemptsByStudent(int studentId) {
        List<TestAttempt> list = new ArrayList<>();
        String sql = "SELECT attempt_id, student_id, test_id, test_name, test_type, " +
                     "total_questions, attempted, correct, incorrect, unanswered, score, " +
                     "accuracy, percentage, started_at, completed_at, status " +
                     "FROM test_attempts WHERE student_id = ? ORDER BY attempt_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
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

    public int countTotalAttempts() {
        String sql = "SELECT COUNT(*) FROM test_attempts";
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

    public Map<String, Object> getStudentPerformanceStats(int studentId) {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT COUNT(*) AS total_tests, " +
                     "COALESCE(SUM(total_questions), 0) AS total_q, " +
                     "COALESCE(SUM(attempted), 0) AS total_att, " +
                     "COALESCE(SUM(correct), 0) AS total_corr, " +
                     "COALESCE(SUM(incorrect), 0) AS total_incorr, " +
                     "COALESCE(SUM(unanswered), 0) AS total_unans, " +
                     "COALESCE(SUM(score), 0) AS total_score " +
                     "FROM test_attempts WHERE student_id = ? AND status = 'COMPLETED'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalTests = rs.getInt("total_tests");
                    int totalQ = rs.getInt("total_q");
                    int totalAtt = rs.getInt("total_att");
                    int totalCorr = rs.getInt("total_corr");
                    int totalIncorr = rs.getInt("total_incorr");
                    int totalUnans = rs.getInt("total_unans");
                    double totalScore = rs.getDouble("total_score");

                    double overallAccuracy = totalAtt > 0 ? ((double) totalCorr / totalAtt) * 100.0 : 0.0;

                    stats.put("totalTests", totalTests);
                    stats.put("totalQuestions", totalQ);
                    stats.put("totalAttempted", totalAtt);
                    stats.put("totalCorrect", totalCorr);
                    stats.put("totalIncorrect", totalIncorr);
                    stats.put("totalUnanswered", totalUnans);
                    stats.put("totalScore", totalScore);
                    stats.put("overallAccuracy", Math.round(overallAccuracy * 100.0) / 100.0);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (stats.isEmpty()) {
            stats.put("totalTests", 0);
            stats.put("totalQuestions", 0);
            stats.put("totalAttempted", 0);
            stats.put("totalCorrect", 0);
            stats.put("totalIncorrect", 0);
            stats.put("totalUnanswered", 0);
            stats.put("totalScore", 0.0);
            stats.put("overallAccuracy", 0.0);
        }

        return stats;
    }

    public List<Map<String, Object>> getStudentWeekWiseStats(int studentId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT q.week_number, " +
                     "COUNT(sa.answer_id) AS total_answered, " +
                     "SUM(CASE WHEN sa.is_correct = 1 THEN 1 ELSE 0 END) AS total_correct " +
                     "FROM student_answers sa " +
                     "JOIN test_attempts ta ON sa.attempt_id = ta.attempt_id " +
                     "JOIN questions q ON sa.question_id = q.question_id " +
                     "WHERE ta.student_id = ? " +
                     "GROUP BY q.week_number " +
                     "ORDER BY q.week_number ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    int wNum = rs.getInt("week_number");
                    int answered = rs.getInt("total_answered");
                    int correct = rs.getInt("total_correct");
                    double acc = answered > 0 ? ((double) correct / answered) * 100.0 : 0.0;

                    row.put("weekNumber", wNum);
                    row.put("totalAnswered", answered);
                    row.put("totalCorrect", correct);
                    row.put("accuracy", Math.round(acc * 100.0) / 100.0);
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean saveStudentAnswer(StudentAnswer answer) {
        String checkSql = "SELECT answer_id FROM student_answers WHERE attempt_id = ? AND question_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement checkPs = con.prepareStatement(checkSql)) {
            checkPs.setInt(1, answer.getAttemptId());
            checkPs.setInt(2, answer.getQuestionId());
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    int ansId = rs.getInt("answer_id");
                    String updateSql = "UPDATE student_answers SET selected_option = ?, is_correct = ?, " +
                                       "answered_at = CURRENT_TIMESTAMP WHERE answer_id = ?";
                    try (PreparedStatement upPs = con.prepareStatement(updateSql)) {
                        upPs.setString(1, answer.getSelectedOption());
                        upPs.setBoolean(2, answer.isCorrect());
                        upPs.setInt(3, ansId);
                        return upPs.executeUpdate() > 0;
                    }
                }
            }

            String insertSql = "INSERT INTO student_answers (attempt_id, question_id, selected_option, " +
                               "correct_option_snapshot, is_correct, question_text_snapshot, " +
                               "option_a_snapshot, option_b_snapshot, option_c_snapshot, option_d_snapshot, " +
                               "explanation_snapshot) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement inPs = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                inPs.setInt(1, answer.getAttemptId());
                inPs.setInt(2, answer.getQuestionId());
                inPs.setString(3, answer.getSelectedOption());
                inPs.setString(4, answer.getCorrectOptionSnapshot());
                inPs.setBoolean(5, answer.isCorrect());
                inPs.setString(6, answer.getQuestionTextSnapshot());
                inPs.setString(7, answer.getOptionASnapshot());
                inPs.setString(8, answer.getOptionBSnapshot());
                inPs.setString(9, answer.getOptionCSnapshot());
                inPs.setString(10, answer.getOptionDSnapshot());
                inPs.setString(11, answer.getExplanationSnapshot());

                int affected = inPs.executeUpdate();
                if (affected > 0) {
                    try (ResultSet keys = inPs.getGeneratedKeys()) {
                        if (keys.next()) {
                            answer.setAnswerId(keys.getInt(1));
                        }
                    }
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<StudentAnswer> getStudentAnswersByAttempt(int attemptId) {
        List<StudentAnswer> list = new ArrayList<>();
        String sql = "SELECT answer_id, attempt_id, question_id, selected_option, " +
                     "correct_option_snapshot, is_correct, question_text_snapshot, " +
                     "option_a_snapshot, option_b_snapshot, option_c_snapshot, option_d_snapshot, " +
                     "explanation_snapshot, answered_at " +
                     "FROM student_answers WHERE attempt_id = ? ORDER BY answer_id ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentAnswer a = new StudentAnswer();
                    a.setAnswerId(rs.getInt("answer_id"));
                    a.setAttemptId(rs.getInt("attempt_id"));
                    a.setQuestionId(rs.getInt("question_id"));
                    a.setSelectedOption(rs.getString("selected_option"));
                    a.setCorrectOptionSnapshot(rs.getString("correct_option_snapshot"));
                    a.setCorrect(rs.getBoolean("is_correct"));
                    a.setQuestionTextSnapshot(rs.getString("question_text_snapshot"));
                    a.setOptionASnapshot(rs.getString("option_a_snapshot"));
                    a.setOptionBSnapshot(rs.getString("option_b_snapshot"));
                    a.setOptionCSnapshot(rs.getString("option_c_snapshot"));
                    a.setOptionDSnapshot(rs.getString("option_d_snapshot"));
                    a.setExplanationSnapshot(rs.getString("explanation_snapshot"));
                    a.setAnsweredAt(rs.getTimestamp("answered_at"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private TestAttempt mapRow(ResultSet rs) throws SQLException {
        TestAttempt t = new TestAttempt();
        t.setAttemptId(rs.getInt("attempt_id"));
        t.setStudentId(rs.getInt("student_id"));
        int tid = rs.getInt("test_id");
        if (!rs.wasNull()) {
            t.setTestId(tid);
        }
        t.setTestName(rs.getString("test_name"));
        t.setTestType(rs.getString("test_type"));
        t.setTotalQuestions(rs.getInt("total_questions"));
        t.setAttempted(rs.getInt("attempted"));
        t.setCorrect(rs.getInt("correct"));
        t.setIncorrect(rs.getInt("incorrect"));
        t.setUnanswered(rs.getInt("unanswered"));
        t.setScore(rs.getDouble("score"));
        t.setAccuracy(rs.getDouble("accuracy"));
        t.setPercentage(rs.getDouble("percentage"));
        t.setStartedAt(rs.getTimestamp("started_at"));
        t.setCompletedAt(rs.getTimestamp("completed_at"));
        t.setStatus(rs.getString("status"));
        return t;
    }
}
