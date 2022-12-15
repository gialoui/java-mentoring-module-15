-- 1. Select all primary skills that contain more than one word (please note that both ‘-‘ and ‘ ’ could be used as a separator)
SELECT * FROM module_15.student
WHERE (LENGTH(primary_skill) - LENGTH(REPLACE(primary_skill, ' ', '')) + 1) > 1 OR (LENGTH(primary_skill) - LENGTH(REPLACE(primary_skill, '-', '')) + 1) > 1;

-- 2. Select all students who do not have a second name / surname (it is absent or consists of only one letter/letter with a dot)
SELECT * FROM module_15.student
WHERE surname IS NULL OR LENGTH(surname) < 2;

-- 3. Select number of students passed exams for each subject and order result by a number of student descending.
SELECT s.name, COUNT(er.student_id) AS no_of_students
FROM module_15.exam_result er INNER JOIN module_15.subject s ON er.subject_id = s.id
WHERE er.mark >= 5
GROUP BY s.name
ORDER BY COUNT(er.student_id) DESC;

-- 4. Select number of students with the same exam marks for each subject.
SELECT s.name, er.mark, COUNT(er.student_id) AS no_of_students
FROM module_15.exam_result er INNER JOIN module_15.subject s ON er.subject_id = s.id
WHERE er.mark >= 5
GROUP BY s.id, er.mark;

-- 5. Select students who passed at least two exams for different subjects
SELECT s.name, COUNT(er.subject_id) AS no_of_passed_subjects
FROM module_15.exam_result er INNER JOIN module_15.student s ON er.student_id = s.id
WHERE er.mark >= 5
GROUP BY s.id
HAVING COUNT(er.subject_id) >= 2

-- 6. Select students who passed at least two exams for the same subject.
SELECT s.name, s.surname
FROM module_15.exam_result er INNER JOIN module_15.student s ON er.student_id = s.id
WHERE er.mark >= 5
GROUP BY s.id, er.subject_id
HAVING COUNT(*) >= 2;

-- 7. Select all subjects which exams passed only students with the same primary skills.
-- It means that all students passed the exam for the one subject must have same primary skill
SELECT *
FROM module_15.subject su
WHERE su.id IN (SELECT er.subject_id
	FROM module_15.exam_result er 
	INNER JOIN module_15.student st ON er.student_id = st.id
	WHERE er.mark >= 5
	GROUP BY er.subject_id
	HAVING COUNT(DISTINCT st.primary_skill) = 1)

-- 8. Select all subjects which exams passed only students with the different primary skills. 
-- It means that all students passed the exam for the one subject must have different primary skill
SELECT *
FROM module_15.subject su
WHERE su.id IN (SELECT er.subject_id
	FROM module_15.exam_result er 
	INNER JOIN module_15.student st ON er.student_id = st.id
	WHERE er.mark >= 5
	GROUP BY er.subject_id
	HAVING COUNT(DISTINCT st.primary_skill) = COUNT(DISTINCT er.student_id))

-- 9. Select students who does not pass any exam using each the following operator: 
-- Outer join
SELECT s.name, s.surname
FROM module_15.student s LEFT OUTER JOIN module_15.exam_result er ON er.student_id = s.id AND er.mark >= 5
WHERE er.mark IS NULL

-- Subquery with ‘not in’ clause
SELECT s.name, s.surname
FROM module_15.student s
WHERE s.id NOT IN (SELECT er.student_id FROM module_15.exam_result er WHERE er.mark >= 5)

-- Subquery with ‘any‘ clause.
SELECT s.name, s.surname
FROM module_15.student s
WHERE s.id != ALL (SELECT er.student_id FROM module_15.exam_result er WHERE er.mark >= 5)

-- Check which approach is faster for 1000, 10K, 100K exams and 10, 1K, 100K students


-- 10. Select all students whose average mark is bigger than overall average mark.
SELECT s.name, s.surname, AVG(er.mark) AS Average
FROM module_15.student s INNER JOIN module_15.exam_result er ON er.student_id = s.id
GROUP BY s.id
HAVING AVG(er.mark) > (SELECT AVG(mark) FROM module_15.exam_result);

-- 11. Select top 5 students who passed their last exam better than average students.
SELECT s.name, s.surname
FROM module_15.student s INNER JOIN module_15.exam_result er ON er.student_id = s.id
WHERE er.id IN (SELECT MAX(er.id) FROM module_15.exam_result er WHERE er.mark >= 5 GROUP BY er.student_id)
GROUP BY s.id
HAVING AVG(er.mark) > (SELECT AVG(mark) FROM module_15.exam_result) 
LIMIT 5;

-- 12. Select biggest mark for each student and add text description for the mark (use COALESCE and WHEN operators)
-- In case if student has not passed any exam ‘not passed' should be returned.
SELECT s.id, CASE 
		WHEN MAX(er.mark) >= 1 AND MAX(er.mark) <= 3 THEN 'BAD'
		WHEN MAX(er.mark) > 3 AND MAX(er.mark) <= 6 THEN 'AVERAGE'
		WHEN MAX(er.mark) > 6 AND MAX(er.mark) <= 8 THEN 'GOOD'
		WHEN MAX(er.mark) > 8 AND MAX(er.mark) <= 10 THEN 'EXCELLENT'
		ELSE 'NOT PASSED'
	END result
FROM module_15.exam_result er RIGHT JOIN module_15.student s ON er.student_id = s.id
GROUP BY s.id

-- 13. Select the number of all marks for each mark type (‘BAD’, ‘AVERAGE’,…)
SELECT SUM(CASE 
			WHEN er.mark >= 1 AND er.mark <= 3 THEN 1
		   	ELSE 0
		   END
		) bad,
		SUM(CASE 
			WHEN er.mark > 3 AND er.mark <= 6 THEN 1
		   	ELSE 0
		   END
		) average,
		SUM(CASE 
			WHEN er.mark > 6 AND er.mark <= 8 THEN 1
		   	ELSE 0
		   END
		) good,
		SUM(CASE 
			WHEN er.mark > 8 AND er.mark <= 10 THEN 1
		   	ELSE 0
		   END
		) excellence
FROM module_15.exam_result er