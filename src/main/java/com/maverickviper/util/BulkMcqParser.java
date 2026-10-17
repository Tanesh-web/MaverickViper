package com.maverickviper.util;

import com.maverickviper.model.ParsedQuestion;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class BulkMcqParser {

    private static final Pattern WEEK_HEADER_PATTERN =
            Pattern.compile("(?i)^\\s*(?:Week\\s*[:\\-]?\\s*|Week\\s+)(\\d+)");

    private static final Pattern QUESTION_START_PATTERN =
            Pattern.compile("(?i)^\\s*(?:Q(?:uestion)?\\s*\\.?\\s*(\\d+)?\\s*[:.)-]?|(\\d+)\\s*[:.)-]\\s*)(.*)$");

    private static final Pattern OPTION_INLINE_PATTERN =
            Pattern.compile("(?i)(?:^|\\s+)([A-D])\\s*[.:)]\\s*");

    private static final Pattern CORRECT_ANSWER_PATTERN =
            Pattern.compile("(?i)^\\s*(?:Correct\\s*Answer|Correct\\s*Option|Answer|Ans)\\s*[:.)-]?\\s*(.*)$");

    private static final Pattern EXPLANATION_PATTERN =
            Pattern.compile("(?i)^\\s*(?:Explanation|Explain|Exp|Note)\\s*[:.)-]?\\s*(.*)$");

    /**
     * Parses plain text / pasted text.
     */
    public static List<ParsedQuestion> parseText(String rawText, int defaultWeek, String defaultCategory) {
        if (rawText == null || rawText.trim().isEmpty()) {
            return Collections.emptyList();
        }

        String[] lines = rawText.split("\\R");
        List<ParsedQuestion> questions = new ArrayList<>();

        ParsedQuestion current = null;
        int currentWeek = defaultWeek;
        String currentCategory = (defaultCategory == null || defaultCategory.isEmpty()) ? "WEEKWISE" : defaultCategory;
        int tempCounter = 1;

        for (String rawLine : lines) {
            String line = rawLine.trim();
            if (line.isEmpty()) {
                continue;
            }

            // 1. Check Week Header
            Matcher weekMatcher = WEEK_HEADER_PATTERN.matcher(line);
            if (weekMatcher.find()) {
                if (current != null) {
                    current.validate();
                    questions.add(current);
                    current = null;
                }
                try {
                    currentWeek = Integer.parseInt(weekMatcher.group(1));
                } catch (NumberFormatException ignored) {}
                continue;
            }

            // Check if mock test header
            if (line.toLowerCase().contains("mock test")) {
                currentCategory = "NPTEL_MOCK_TEST";
            }

            // 2. Check Correct Answer
            Matcher ansMatcher = CORRECT_ANSWER_PATTERN.matcher(line);
            if (ansMatcher.find() && current != null) {
                String ansVal = ansMatcher.group(1).trim();
                current.setCorrectOption(extractAnswerLetter(ansVal, current));
                continue;
            }

            // 3. Check Explanation
            Matcher expMatcher = EXPLANATION_PATTERN.matcher(line);
            if (expMatcher.find() && current != null) {
                current.setExplanation(expMatcher.group(1).trim());
                continue;
            }

            // 4. Check Question start
            Matcher qMatcher = QUESTION_START_PATTERN.matcher(line);
            boolean looksLikeOption = line.matches("(?i)^[A-D]\\s*[.:)].*");

            if (qMatcher.matches() && !looksLikeOption) {
                if (current != null) {
                    current.validate();
                    questions.add(current);
                }
                current = new ParsedQuestion();
                current.setTempId(tempCounter++);
                current.setWeekNumber(currentWeek);
                current.setCategory(currentCategory);

                String rest = qMatcher.group(3);
                if (rest != null && !rest.trim().isEmpty()) {
                    processLineForOptionsOrText(current, rest.trim());
                }
                continue;
            }

            // If we have an active question, parse options or append text
            if (current != null) {
                processLineForOptionsOrText(current, line);
            }
        }

        if (current != null) {
            current.validate();
            questions.add(current);
        }

        detectDuplicates(questions);
        return questions;
    }

    /**
     * Parses Word Document (.docx)
     */
    public static List<ParsedQuestion> parseWord(InputStream is, int defaultWeek, String defaultCategory) throws Exception {
        StringBuilder sb = new StringBuilder();
        try (XWPFDocument doc = new XWPFDocument(is)) {
            for (XWPFParagraph p : doc.getParagraphs()) {
                String text = p.getText();
                if (text != null && !text.isBlank()) {
                    sb.append(text).append("\n");
                }
            }
            // Also inspect tables if any
            for (XWPFTable table : doc.getTables()) {
                for (XWPFTableRow row : table.getRows()) {
                    for (XWPFTableCell cell : row.getTableCells()) {
                        String ct = cell.getText();
                        if (ct != null && !ct.isBlank()) {
                            sb.append(ct).append("\n");
                        }
                    }
                }
            }
        }
        return parseText(sb.toString(), defaultWeek, defaultCategory);
    }

    /**
     * Parses Excel Document (.xlsx)
     */
    public static List<ParsedQuestion> parseExcel(InputStream is, int defaultWeek, String defaultCategory) throws Exception {
        List<ParsedQuestion> questions = new ArrayList<>();
        int tempCounter = 1;

        try (Workbook workbook = new XSSFWorkbook(is)) {
            Sheet sheet = workbook.getSheetAt(0);
            if (sheet == null) return questions;

            int startRow = 0;
            Row firstRow = sheet.getRow(0);
            if (firstRow != null) {
                Cell c0 = firstRow.getCell(0);
                if (c0 != null) {
                    String val = getCellString(c0).toLowerCase();
                    if (val.contains("question") || val.contains("q.")) {
                        startRow = 1; // Header row
                    }
                }
            }

            for (int r = startRow; r <= sheet.getLastRowNum(); r++) {
                Row row = sheet.getRow(r);
                if (row == null) continue;

                String col0 = getCellString(row.getCell(0));
                if (col0 == null || col0.trim().isEmpty()) continue;

                // Check if this is a single text column or multiple columns
                String col1 = getCellString(row.getCell(1));
                String col2 = getCellString(row.getCell(2));
                String col3 = getCellString(row.getCell(3));
                String col4 = getCellString(row.getCell(4));
                String col5 = getCellString(row.getCell(5)); // Correct Answer
                String col6 = getCellString(row.getCell(6)); // Week
                String col7 = getCellString(row.getCell(7)); // Explanation

                if (col1 != null && !col1.trim().isEmpty() &&
                    col2 != null && !col2.trim().isEmpty()) {
                    // Columnar format: Q, A, B, C, D, Answer, [Week], [Explanation]
                    ParsedQuestion pq = new ParsedQuestion();
                    pq.setTempId(tempCounter++);
                    pq.setQuestionText(cleanQuestionPrefix(col0));
                    pq.setOptionA(cleanOptionPrefix(col1));
                    pq.setOptionB(cleanOptionPrefix(col2));
                    pq.setOptionC(cleanOptionPrefix(col3 != null ? col3 : ""));
                    pq.setOptionD(cleanOptionPrefix(col4 != null ? col4 : ""));

                    String ans = extractAnswerLetter(col5, pq);
                    pq.setCorrectOption(ans);

                    int week = defaultWeek;
                    if (col6 != null && !col6.trim().isEmpty()) {
                        try {
                            week = (int) Double.parseDouble(col6.trim().replaceAll("[^0-9.]", ""));
                        } catch (Exception ignored) {}
                    }
                    pq.setWeekNumber(week);
                    pq.setCategory(defaultCategory == null ? "WEEKWISE" : defaultCategory);
                    if (col7 != null && !col7.trim().isEmpty()) {
                        pq.setExplanation(col7.trim());
                    }

                    pq.validate();
                    questions.add(pq);
                } else {
                    // Entire block in column 0 or multiline cell
                    List<ParsedQuestion> blockQuestions = parseText(col0, defaultWeek, defaultCategory);
                    questions.addAll(blockQuestions);
                }
            }
        }

        detectDuplicates(questions);
        return questions;
    }

    /**
     * Parses CSV format.
     */
    public static List<ParsedQuestion> parseCsv(InputStream is, int defaultWeek, String defaultCategory) throws Exception {
        List<ParsedQuestion> questions = new ArrayList<>();
        int tempCounter = 1;

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            boolean isFirst = true;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;

                List<String> cols = parseCsvLine(line);
                if (cols.isEmpty()) continue;

                if (isFirst) {
                    isFirst = false;
                    String firstCol = cols.get(0).toLowerCase();
                    if (firstCol.contains("question") || firstCol.contains("q.")) {
                        continue; // Skip header
                    }
                }

                if (cols.size() >= 5) {
                    ParsedQuestion pq = new ParsedQuestion();
                    pq.setTempId(tempCounter++);
                    pq.setQuestionText(cleanQuestionPrefix(cols.get(0)));
                    pq.setOptionA(cleanOptionPrefix(cols.get(1)));
                    pq.setOptionB(cleanOptionPrefix(cols.get(2)));
                    pq.setOptionC(cols.size() > 3 ? cleanOptionPrefix(cols.get(3)) : "");
                    pq.setOptionD(cols.size() > 4 ? cleanOptionPrefix(cols.get(4)) : "");

                    String ans = cols.size() > 5 ? extractAnswerLetter(cols.get(5), pq) : "";
                    pq.setCorrectOption(ans);

                    int week = defaultWeek;
                    if (cols.size() > 6 && !cols.get(6).trim().isEmpty()) {
                        try {
                            week = Integer.parseInt(cols.get(6).replaceAll("[^0-9]", ""));
                        } catch (Exception ignored) {}
                    }
                    pq.setWeekNumber(week);
                    pq.setCategory(defaultCategory == null ? "WEEKWISE" : defaultCategory);

                    if (cols.size() > 7) {
                        pq.setExplanation(cols.get(7).trim());
                    }

                    pq.validate();
                    questions.add(pq);
                } else {
                    // Single or unstructured column
                    List<ParsedQuestion> sub = parseText(cols.get(0), defaultWeek, defaultCategory);
                    questions.addAll(sub);
                }
            }
        }

        detectDuplicates(questions);
        return questions;
    }

    private static void processLineForOptionsOrText(ParsedQuestion question, String line) {
        Matcher matcher = OPTION_INLINE_PATTERN.matcher(line);
        List<Integer> starts = new ArrayList<>();
        List<Integer> ends = new ArrayList<>();
        List<String> letters = new ArrayList<>();

        while (matcher.find()) {
            starts.add(matcher.start(1));
            ends.add(matcher.end());
            letters.add(matcher.group(1).toUpperCase());
        }

        if (starts.isEmpty()) {
            // No options on this line
            if (question.getQuestionText().isEmpty()) {
                question.setQuestionText(line.trim());
            } else if (!question.getOptionD().isEmpty()) {
                question.setOptionD(question.getOptionD() + " " + line.trim());
            } else if (!question.getOptionC().isEmpty()) {
                question.setOptionC(question.getOptionC() + " " + line.trim());
            } else if (!question.getOptionB().isEmpty()) {
                question.setOptionB(question.getOptionB() + " " + line.trim());
            } else if (!question.getOptionA().isEmpty()) {
                question.setOptionA(question.getOptionA() + " " + line.trim());
            } else {
                question.setQuestionText(question.getQuestionText() + " " + line.trim());
            }
            return;
        }

        // Question part before first option
        String qPart = line.substring(0, starts.get(0)).trim();
        if (!qPart.isEmpty()) {
            if (question.getQuestionText().isEmpty()) {
                question.setQuestionText(qPart);
            } else {
                question.setQuestionText(question.getQuestionText() + " " + qPart);
            }
        }

        for (int i = 0; i < starts.size(); i++) {
            int start = ends.get(i);
            int end = (i + 1 < starts.size()) ? starts.get(i + 1) : line.length();
            String optText = line.substring(start, end).trim();

            switch (letters.get(i)) {
                case "A": question.setOptionA(optText); break;
                case "B": question.setOptionB(optText); break;
                case "C": question.setOptionC(optText); break;
                case "D": question.setOptionD(optText); break;
            }
        }
    }

    private static String extractAnswerLetter(String answerStr, ParsedQuestion q) {
        if (answerStr == null || answerStr.trim().isEmpty()) return "";
        String trimmed = answerStr.trim();

        Matcher m = Pattern.compile("(?i)^\\s*\\(?([A-D])\\)?").matcher(trimmed);
        if (m.find()) {
            return m.group(1).toUpperCase();
        }

        if (q != null) {
            if (!q.getOptionA().isEmpty() && trimmed.equalsIgnoreCase(q.getOptionA())) return "A";
            if (!q.getOptionB().isEmpty() && trimmed.equalsIgnoreCase(q.getOptionB())) return "B";
            if (!q.getOptionC().isEmpty() && trimmed.equalsIgnoreCase(q.getOptionC())) return "C";
            if (!q.getOptionD().isEmpty() && trimmed.equalsIgnoreCase(q.getOptionD())) return "D";
        }

        return "";
    }

    private static String cleanQuestionPrefix(String text) {
        if (text == null) return "";
        return text.replaceFirst("(?i)^\\s*(?:Q(?:uestion)?\\s*\\.?\\s*\\d*\\s*[:.)-]?|\\d+\\s*[:.)-]\\s*)", "").trim();
    }

    private static String cleanOptionPrefix(String text) {
        if (text == null) return "";
        return text.replaceFirst("(?i)^\\s*[A-D]\\s*[.:)]\\s*", "").trim();
    }

    private static String getCellString(Cell cell) {
        if (cell == null) return "";
        CellType type = cell.getCellType();
        if (type == CellType.STRING) {
            return cell.getStringCellValue();
        } else if (type == CellType.NUMERIC) {
            double d = cell.getNumericCellValue();
            if (d == (long) d) {
                return String.valueOf((long) d);
            }
            return String.valueOf(d);
        } else if (type == CellType.BOOLEAN) {
            return String.valueOf(cell.getBooleanCellValue());
        } else if (type == CellType.FORMULA) {
            try {
                return cell.getStringCellValue();
            } catch (Exception e) {
                return String.valueOf(cell.getNumericCellValue());
            }
        }
        return "";
    }

    private static List<String> parseCsvLine(String line) {
        List<String> list = new ArrayList<>();
        boolean inQuotes = false;
        StringBuilder sb = new StringBuilder();
        char delimiter = line.contains("\t") ? '\t' : (line.contains(";") ? ';' : ',');

        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == delimiter && !inQuotes) {
                list.add(sb.toString().trim());
                sb.setLength(0);
            } else {
                sb.append(c);
            }
        }
        list.add(sb.toString().trim());
        return list;
    }

    private static void detectDuplicates(List<ParsedQuestion> questions) {
        Set<String> seen = new HashSet<>();
        for (ParsedQuestion q : questions) {
            if (q.getQuestionText() != null && !q.getQuestionText().isEmpty()) {
                String norm = q.getQuestionText().replaceAll("\\s+", " ").toLowerCase().trim();
                if (seen.contains(norm)) {
                    q.setDuplicate(true);
                } else {
                    seen.add(norm);
                }
            }
        }
    }
}
