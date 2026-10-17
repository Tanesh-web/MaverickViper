package com.maverickviper.admin;

import com.maverickviper.dao.QuestionDAO;
import com.maverickviper.dao.WeekDAO;
import com.maverickviper.model.ParsedQuestion;
import com.maverickviper.model.Question;
import com.maverickviper.model.Week;
import com.maverickviper.util.BulkMcqParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/bulk-question-upload")
@MultipartConfig(
        maxFileSize = 20 * 1024 * 1024,
        maxRequestSize = 25 * 1024 * 1024
)
public class BulkQuestionUploadServlet extends HttpServlet {

    private final QuestionDAO questionDAO = new QuestionDAO();
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
        List<Week> weeks = weekDAO.getAllWeeks(courseId);
        request.setAttribute("weeks", weeks);

        // Check if clearing preview
        if ("reset".equalsIgnoreCase(request.getParameter("mode"))) {
            session.removeAttribute("previewQuestions");
        }

        request.getRequestDispatcher("/bulk-upload.jsp").forward(request, response);
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
        List<Week> weeks = weekDAO.getAllWeeks(courseId);
        request.setAttribute("weeks", weeks);

        if ("commit".equalsIgnoreCase(action)) {
            handleCommit(request, response, session, courseId);
        } else {
            handleParse(request, response, session, courseId);
        }
    }

    private void handleParse(HttpServletRequest request, HttpServletResponse response,
                             HttpSession session, int courseId) throws ServletException, IOException {

        String importType = request.getParameter("importType"); // TEXT, DOCX, XLSX, CSV
        String defaultWeekParam = request.getParameter("defaultWeek");
        String defaultCategory = request.getParameter("defaultCategory");

        int defaultWeek = 0;
        if (defaultWeekParam != null && !defaultWeekParam.trim().isEmpty()) {
            try {
                defaultWeek = Integer.parseInt(defaultWeekParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        if (defaultCategory == null || defaultCategory.trim().isEmpty()) {
            defaultCategory = "WEEKWISE";
        }

        List<ParsedQuestion> parsedQuestions = new ArrayList<>();
        String errorMsg = null;

        try {
            if ("TEXT".equalsIgnoreCase(importType)) {
                String rawText = request.getParameter("rawText");
                if (rawText == null || rawText.trim().isEmpty()) {
                    errorMsg = "Please paste question text into the input area.";
                } else {
                    parsedQuestions = BulkMcqParser.parseText(rawText, defaultWeek, defaultCategory);
                }
            } else {
                Part filePart = request.getPart("file");
                if (filePart == null || filePart.getSize() == 0) {
                    errorMsg = "Please select a file to upload.";
                } else {
                    String submittedFileName = filePart.getSubmittedFileName();
                    String lowerName = (submittedFileName != null) ? submittedFileName.toLowerCase() : "";

                    try (InputStream is = filePart.getInputStream()) {
                        if ("DOCX".equalsIgnoreCase(importType) || lowerName.endsWith(".docx")) {
                            parsedQuestions = BulkMcqParser.parseWord(is, defaultWeek, defaultCategory);
                        } else if ("XLSX".equalsIgnoreCase(importType) || lowerName.endsWith(".xlsx")) {
                            parsedQuestions = BulkMcqParser.parseExcel(is, defaultWeek, defaultCategory);
                        } else if ("CSV".equalsIgnoreCase(importType) || lowerName.endsWith(".csv")) {
                            parsedQuestions = BulkMcqParser.parseCsv(is, defaultWeek, defaultCategory);
                        } else {
                            errorMsg = "Unsupported file format. Please upload .docx, .xlsx, or .csv.";
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            errorMsg = "Parsing error: " + e.getMessage();
        }

        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
        } else if (parsedQuestions.isEmpty()) {
            request.setAttribute("error", "No questions could be recognized from the input. Please check the expected format.");
        } else {
            session.setAttribute("previewQuestions", parsedQuestions);
            session.setAttribute("previewDefaultWeek", defaultWeek);
            session.setAttribute("previewDefaultCategory", defaultCategory);
        }

        request.getRequestDispatcher("/bulk-upload.jsp").forward(request, response);
    }

    private void handleCommit(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session, int courseId) throws ServletException, IOException {

        List<ParsedQuestion> sessionQuestions = (List<ParsedQuestion>) session.getAttribute("previewQuestions");
        if (sessionQuestions == null || sessionQuestions.isEmpty()) {
            response.sendRedirect("bulk-question-upload?error=no_preview");
            return;
        }

        // Apply any inline edits submitted from the preview form
        String[] qTexts = request.getParameterValues("qText");
        String[] optAs = request.getParameterValues("optA");
        String[] optBs = request.getParameterValues("optB");
        String[] optCs = request.getParameterValues("optC");
        String[] optDs = request.getParameterValues("optD");
        String[] correctOpts = request.getParameterValues("correctOpt");
        String[] weekNums = request.getParameterValues("weekNum");
        String[] categories = request.getParameterValues("category");
        String[] explanations = request.getParameterValues("explanation");

        List<Question> questionsToInsert = new ArrayList<>();

        if (qTexts != null) {
            for (int i = 0; i < qTexts.length; i++) {
                String qText = qTexts[i] != null ? qTexts[i].trim() : "";
                String a = (optAs != null && i < optAs.length) ? optAs[i].trim() : "";
                String b = (optBs != null && i < optBs.length) ? optBs[i].trim() : "";
                String c = (optCs != null && i < optCs.length) ? optCs[i].trim() : "";
                String d = (optDs != null && i < optDs.length) ? optDs[i].trim() : "";
                String correct = (correctOpts != null && i < correctOpts.length) ? correctOpts[i].trim().toUpperCase() : "";
                int weekNum = 0;
                if (weekNums != null && i < weekNums.length && !weekNums[i].trim().isEmpty()) {
                    try {
                        weekNum = Integer.parseInt(weekNums[i].trim());
                    } catch (NumberFormatException ignored) {}
                }
                String cat = (categories != null && i < categories.length && !categories[i].trim().isEmpty()) ? categories[i].trim() : "WEEKWISE";
                String exp = (explanations != null && i < explanations.length && !explanations[i].trim().isEmpty()) ? explanations[i].trim() : null;

                // Validate item
                if (!qText.isEmpty() && !a.isEmpty() && !b.isEmpty() && !c.isEmpty() && !d.isEmpty() && correct.matches("^[ABCD]$")) {
                    Week w = weekDAO.getWeekByNumber(courseId, weekNum);
                    Integer weekId = (w != null) ? w.getWeekId() : null;

                    Question q = new Question();
                    q.setCourseId(courseId);
                    q.setWeekId(weekId);
                    q.setWeekNumber(weekNum);
                    q.setQuestionText(qText);
                    q.setOptionA(a);
                    q.setOptionB(b);
                    q.setOptionC(c);
                    q.setOptionD(d);
                    q.setCorrectOption(correct);
                    q.setCategory(cat);
                    q.setExplanation(exp);

                    questionsToInsert.add(q);
                }
            }
        }

        try {
            int inserted = questionDAO.batchInsertQuestions(courseId, questionsToInsert);
            session.removeAttribute("previewQuestions");
            request.setAttribute("success", "Successfully imported " + inserted + " questions into MySQL repository!");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database transaction failed: " + e.getMessage());
        }

        request.getRequestDispatcher("/bulk-upload.jsp").forward(request, response);
    }
}
