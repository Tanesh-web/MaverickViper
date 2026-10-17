package com.maverickviper.admin;

import com.maverickviper.config.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/add-question")
public class AddQuestionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        List<String[]> courses = new ArrayList<>();

        String sql = "SELECT course_id, course_name FROM courses ORDER BY course_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                courses.add(new String[]{
                    String.valueOf(rs.getInt("course_id")),
                    rs.getString("course_name")
                });
            }

            request.setAttribute("courses", courses);
            request.getRequestDispatcher("/add-question.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Unable to load courses.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String courseId = request.getParameter("courseId");
        String weekNumber = request.getParameter("weekNumber");
        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctOption = request.getParameter("correctOption");

        if (courseId == null || weekNumber == null
                || questionText == null || questionText.trim().isEmpty()
                || optionA == null || optionA.trim().isEmpty()
                || optionB == null || optionB.trim().isEmpty()
                || optionC == null || optionC.trim().isEmpty()
                || optionD == null || optionD.trim().isEmpty()
                || correctOption == null
                || !correctOption.matches("[ABCD]")) {

            response.sendRedirect("add-question?error=invalid");
            return;
        }

        try {
            int course = Integer.parseInt(courseId);
            int week = Integer.parseInt(weekNumber);

            if (course <= 0 || week <= 0) {
                response.sendRedirect("add-question?error=invalid");
                return;
            }

            String sql = "INSERT INTO questions "
                    + "(course_id, week_number, question_text, "
                    + "option_a, option_b, option_c, option_d, correct_option) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, course);
                ps.setInt(2, week);
                ps.setString(3, questionText.trim());
                ps.setString(4, optionA.trim());
                ps.setString(5, optionB.trim());
                ps.setString(6, optionC.trim());
                ps.setString(7, optionD.trim());
                ps.setString(8, correctOption);

                ps.executeUpdate();
            }

            response.sendRedirect("add-question?success=added");

        } catch (NumberFormatException e) {
            response.sendRedirect("add-question?error=invalid");
        } catch (Exception e) {
            throw new ServletException("Unable to save question.", e);
        }
    }
}