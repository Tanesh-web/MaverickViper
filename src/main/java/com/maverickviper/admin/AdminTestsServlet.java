package com.maverickviper.admin;

import com.maverickviper.dao.TestDAO;
import com.maverickviper.dao.WeekDAO;
import com.maverickviper.model.TestModel;
import com.maverickviper.model.Week;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin-tests")
public class AdminTestsServlet extends HttpServlet {

    private final TestDAO testDAO = new TestDAO();
    private final WeekDAO weekDAO = new WeekDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        int courseId = 1;
        List<TestModel> tests = testDAO.getAllTests(courseId);
        List<Week> weeks = weekDAO.getAllWeeks(courseId);

        request.setAttribute("tests", tests);
        request.setAttribute("weeks", weeks);

        request.getRequestDispatcher("/admin-tests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        int courseId = 1;

        if ("delete".equalsIgnoreCase(action)) {
            try {
                int testId = Integer.parseInt(request.getParameter("testId"));
                testDAO.deleteTest(testId);
                response.sendRedirect("admin-tests?success=deleted");
            } catch (Exception e) {
                response.sendRedirect("admin-tests?error=delete_failed");
            }
            return;
        }

        String testName = request.getParameter("testName");
        String testType = request.getParameter("testType");
        String weekIdParam = request.getParameter("weekId");
        String durationParam = request.getParameter("durationMinutes");
        String marksParam = request.getParameter("marksPerQuestion");
        String negMarksParam = request.getParameter("negativeMarks");
        String shuffleOptionsParam = request.getParameter("shuffleOptions");
        String totalQParam = request.getParameter("totalQuestions");

        if (testName == null || testType == null || testName.trim().isEmpty()) {
            response.sendRedirect("admin-tests?error=empty");
            return;
        }

        try {
            TestModel t = new TestModel();
            t.setCourseId(courseId);
            t.setTestName(testName.trim());
            t.setTestType(testType.trim());

            if (weekIdParam != null && !weekIdParam.trim().isEmpty() && !weekIdParam.equals("-1")) {
                t.setWeekId(Integer.parseInt(weekIdParam.trim()));
            }

            t.setDurationMinutes(durationParam != null && !durationParam.trim().isEmpty() ? Integer.parseInt(durationParam.trim()) : 30);
            t.setMarksPerQuestion(marksParam != null && !marksParam.trim().isEmpty() ? Double.parseDouble(marksParam.trim()) : 1.0);
            t.setNegativeMarks(negMarksParam != null && !negMarksParam.trim().isEmpty() ? Double.parseDouble(negMarksParam.trim()) : 0.0);
            t.setShuffleOptions("on".equalsIgnoreCase(shuffleOptionsParam) || "true".equalsIgnoreCase(shuffleOptionsParam));
            t.setTotalQuestions(totalQParam != null && !totalQParam.trim().isEmpty() ? Integer.parseInt(totalQParam.trim()) : 20);

            boolean created = testDAO.createTest(t);
            if (created) {
                response.sendRedirect("admin-tests?success=created");
            } else {
                response.sendRedirect("admin-tests?error=create_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-tests?error=failed");
        }
    }
}
