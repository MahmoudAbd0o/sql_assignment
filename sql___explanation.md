# شرح تفصيلي للـ 20 سؤال SQL — COMPANY DATABASE


كل سؤال فيه: **فكرة السؤال** ثم **الحل** ثم **شرح كل سطر**.


---


## 1) Employees Born Before 1965


**الفكرة:** عايزين نفلتر (Filter) صفوف جدول الموظفين بشرط بسيط على عمود التاريخ، وبعدين نرتبهم.


```sql

SELECT fname, lname, bdate

FROM employee

WHERE bdate < '1965-01-01'

ORDER BY bdate ASC;

```


- `SELECT fname, lname, bdate` → بنحدد الأعمدة اللي عايزين نشوفها بس، مش كل الجدول.

- `FROM employee` → المصدر اللي هنجيب منه البيانات.

- `WHERE bdate < '1965-01-01'` → شرط الفلترة: هات الصفوف اللي تاريخ الميلاد فيها أصغر (أقدم) من أول يناير 1965. التاريخ بيتكتب كنص بصيغة `'YYYY-MM-DD'` وPostgres يقارنه كتاريخ تلقائيًا.

- `ORDER BY bdate ASC;` → رتب النتيجة تصاعديًا حسب تاريخ الميلاد (الأقدم فوق، وده معنى "من الأقدم للأحدث"). `ASC` هي الافتراضية أصلاً لكن كتبناها للوضوح.


---


## 2) Employees With Salary Between 25000 and 40000


**الفكرة:** فلترة على مدى رقمي (نطاق) شامل الطرفين.


```sql

SELECT fname, lname, salary

FROM employee

WHERE salary BETWEEN 25000 AND 40000;

```


- `SELECT fname, lname, salary` → الأعمدة المطلوبة.

- `FROM employee` → الجدول.

- `WHERE salary BETWEEN 25000 AND 40000;` → `BETWEEN X AND Y` معناها `salary >= X AND salary <= Y`، يعني شامل 25000 و40000 نفسهم (مش أكبر منهم بس).


---


## 3) Employees From Specific Departments


**الفكرة:** بدل ما تكتب `dno = 4 OR dno = 5` بتستخدم `IN` لقايمة قيم.


```sql

SELECT fname, lname, dno

FROM employee

WHERE dno IN (4, 5);

```


- `SELECT fname, lname, dno` → الأعمدة المطلوبة (فيه رقم القسم عشان نتأكد بصريًا).

- `WHERE dno IN (4, 5);` → `IN` بتقول للموظف "لو قيمة dno بتاعتك موجودة في القايمة دي (4 أو 5) ظهر". دي اختصار منطقي لـ `dno = 4 OR dno = 5`.


---


## 4) Employees Whose Last Name Starts With S


**الفكرة:** مطابقة نصوص (Pattern Matching) باستخدام `LIKE`.


```sql

SELECT fname, lname, salary

FROM employee

WHERE lname LIKE 'S%';

```


- `WHERE lname LIKE 'S%';` → `LIKE` بتقارن نص بنمط (pattern). علامة `%` معناها "أي عدد من الحروف بعد كده (حتى صفر)". فـ `'S%'` = يبدأ بحرف S وبعده أي حاجة. لو عايز حساسية لحالة الأحرف upper/lower بالظبط ممكن تستخدم `ILIKE` في Postgres (case-insensitive).


---


## 5) Employees With Salary Above 30000 and Born Before 1970


**الفكرة:** الجمع بين أكتر من شرط في نفس الوقت باستخدام `AND` (لازم الاتنين يتحققوا مع بعض).


```sql

SELECT fname, lname, bdate, salary

FROM employee

WHERE salary > 30000

AND bdate < '1970-01-01';

```


- `WHERE salary > 30000` → الشرط الأول: الراتب أكبر (strictly) من 30000.

- `AND bdate < '1970-01-01';` → الشرط الثاني: لازم يتحقق مع الأول سوا. الموظف لازم يحقق الشرطين معًا عشان يظهر في النتيجة.


---


## 6) Department Managers


**الفكرة:** كل قسم عنده مدير هو أصلاً موظف (Employee)، ورقمه القومي (ssn) مخزّن في جدول department كـ mgr_ssn. يعني لازم نربط (JOIN) الجدولين على العمود ده.


```sql

SELECT d.dname, e.fname, e.lname, d.mgr_start_date AS mgrstartdate

FROM department d

JOIN employee e ON d.mgr_ssn = e.ssn;

```


- `FROM department d` → بناخد جدول department ونديله اسم مستعار (alias) `d` عشان الكتابة تبقى أقصر وأوضح.

- `JOIN employee e ON d.mgr_ssn = e.ssn;` → بنربط جدول employee (بلقبه `e`) مع department، وشرط الربط إن `mgr_ssn` في department يساوي `ssn` بتاع الموظف. يعني بندور: "مين الموظف اللي رقمه القومي هو نفسه رقم المدير المسجل في القسم؟"

- `SELECT d.dname, e.fname, e.lname, d.mgr_start_date AS mgrstartdate` → بنجيب اسم القسم من جدول department، واسم/لقب الموظف من جدول employee (لاحظ استخدام `d.` و`e.` عشان نميز مصدر كل عمود، خصوصًا لو الاسم موجود في الجدولين). `AS mgrstartdate` بس عشان نسمي العمود بالاسم المطلوب في المخرجات.


---


## 7) Employees and Their Department Locations


**الفكرة:** الموظف مرتبط بقسم (dno)، والقسم ممكن يكون له أكتر من موقع (location) في جدول منفصل `dept_locations`. فعايزين نربط 3 جداول ورا بعض (سلسلة JOIN).


```sql

SELECT e.fname, e.lname, d.dname, dl.dlocation

FROM employee e

JOIN department d ON e.dno = d.dnumber

JOIN dept_locations dl ON d.dnumber = dl.dnumber;

```


- `FROM employee e` → نبدأ من الموظف.

- `JOIN department d ON e.dno = d.dnumber` → نربط كل موظف بالقسم بتاعه (رقم القسم عند الموظف = رقم القسم في جدول الأقسام).

- `JOIN dept_locations dl ON d.dnumber = dl.dnumber;` → بعد ما عرفنا القسم، نربطه بجدول المواقع على نفس رقم القسم. لو القسم عنده أكتر من صف في dept_locations (أكتر من موقع)، الموظف هيتكرر ظهوره مرة لكل موقع — وده هو التنويه المذكور في السؤال.


---


## 8) Employees Working on ProductX


**الفكرة:** علاقة many-to-many بين employee وproject بيمثلها جدول وسيط `works_on`. لازم نمر بيه عشان نوصل من الموظف للمشروع.


```sql

SELECT e.fname, e.lname, p.pname, w.hours

FROM employee e

JOIN works_on w ON e.ssn = w.essn

JOIN project p ON w.pno = p.pnumber

WHERE p.pname = 'ProductX';

```


- `JOIN works_on w ON e.ssn = w.essn` → نربط الموظف بسجلات عمله (كل سطر في works_on بيمثل: موظف معيّن شغال على مشروع معيّن لعدد ساعات معيّن).

- `JOIN project p ON w.pno = p.pnumber` → من رقم المشروع (pno) في works_on نوصل لتفاصيل المشروع في جدول project.

- `WHERE p.pname = 'ProductX';` → نفلتر بس على المشروع المطلوب اسمه.


---


## 9) Employees Working More Than 20 Hours on a Project


**الفكرة:** نفس فكرة الربط اللي فات، بس الفلتر هنا على عدد الساعات مش اسم مشروع، وبعدين رتب تنازليًا.


```sql

SELECT e.fname, e.lname, p.pname, w.hours

FROM employee e

JOIN works_on w ON e.ssn = w.essn

JOIN project p ON w.pno = p.pnumber

WHERE w.hours > 20

ORDER BY w.hours DESC;

```


- `WHERE w.hours > 20` → بس الصفوف اللي عدد الساعات فيها أكبر من 20.

- `ORDER BY w.hours DESC;` → ترتيب تنازلي (الأكبر فوق)، `DESC` = Descending.


---


## 10) Total Hours for Each Employee


**الفكرة:** ده أول سؤال Aggregation — بدل ما نعرض كل سطر لوحده، عايزين نجمع (SUM) الساعات لكل موظف في صف واحد.


```sql

SELECT e.fname, e.lname, SUM(w.hours) AS total_hours

FROM employee e

JOIN works_on w ON e.ssn = w.essn

GROUP BY e.fname, e.lname, e.ssn;

```


- `SUM(w.hours) AS total_hours` → دالة تجميعية بتجمع كل قيم hours الخاصة بنفس المجموعة (نفس الموظف) في رقم واحد.

- `GROUP BY e.fname, e.lname, e.ssn;` → عشان تستخدم SUM لازم تحدد "هجمع حسب إيه؟" — هنا بنجمع حسب كل موظف. أضفنا `e.ssn` في الـ GROUP BY (مش بس الاسم) عشان لو فيه موظفين نفس الاسم يتفرقوا صح، وده مطلوب في Postgres إن أي عمود مش جوه دالة تجميعية لازم يكون في GROUP BY.

- الـ `JOIN` هنا معناها إننا هنركز بس على الموظفين اللي ليهم سجل في works_on (زي ما الملاحظة قالت).


---


## 11) Number of Projects for Each Employee


**الفكرة:** بدل SUM هنا هنستخدم COUNT عشان نعد كام سطر (مشروع) لكل موظف.


```sql

SELECT e.fname, e.lname, COUNT(w.pno) AS project_count

FROM employee e

JOIN works_on w ON e.ssn = w.essn

GROUP BY e.fname, e.lname, e.ssn;

```


- `COUNT(w.pno) AS project_count` → بيعد عدد الصفوف (مشاريع) المرتبطة بكل موظف في works_on. بنعد العمود pno تحديدًا (مش `*`) عشان لو كانت القيمة NULL ماتتحسبش، لكن عمليًا هنا كل سطر works_on له pno.

- `GROUP BY ...` → نفس فكرة السؤال اللي فات، بنجمع الصفوف حسب كل موظف قبل ما نعد.


---


## 12) Employees Working on Exactly Two Projects


**الفكرة:** نفس السؤال اللي فات، لكن دلوقتي عايزين نفلتر على *نتيجة* الـ COUNT نفسها. الفلترة دي متسمحش بيها WHERE (لأن WHERE بتشتغل قبل التجميع)، فبنستخدم HAVING اللي بيشتغل بعد التجميع.


```sql

SELECT e.fname, e.lname, COUNT(w.pno) AS project_count

FROM employee e

JOIN works_on w ON e.ssn = w.essn

GROUP BY e.fname, e.lname, e.ssn

HAVING COUNT(w.pno) = 2;

```


- `GROUP BY ...` → بنجمع الصفوف حسب كل موظف زي قبل.

- `HAVING COUNT(w.pno) = 2;` → بعد ما اتحسب الـ COUNT لكل مجموعة (موظف)، بنفلتر ونسيب بس اللي عددهم بالظبط 2. الفرق بين WHERE وHAVING: WHERE بتفلتر الصفوف الخام قبل التجميع، وHAVING بتفلتر المجموعات (Groups) بعد ما يتحسب عليها SUM/COUNT/AVG.


---


## 13) Projects With Total Hours Greater Than 30


**الفكرة:** نفس فكرة HAVING بس التجميع دلوقتي من ناحية المشروع مش الموظف.


```sql

SELECT p.pname, SUM(w.hours) AS total_hours

FROM project p

JOIN works_on w ON p.pnumber = w.pno

GROUP BY p.pname

HAVING SUM(w.hours) > 30;

```


- `FROM project p JOIN works_on w ON p.pnumber = w.pno` → نربط كل مشروع بكل السجلات اللي فيها ناس شغالة عليه.

- `GROUP BY p.pname` → التجميع بقى حسب اسم المشروع (كل مشروع = مجموعة واحدة).

- `HAVING SUM(w.hours) > 30;` → بعد جمع الساعات لكل مشروع، اسيب بس المشاريع اللي مجموعها أكبر من 30.


---


## 14) Departments With Average Salary Between 25000 and 40000


**الفكرة:** حساب متوسط (AVG) بدل مجموع، وفلترة النطاق باستخدام BETWEEN مع HAVING.


```sql

SELECT dno, AVG(salary) AS average_salary

FROM employee

GROUP BY dno

HAVING AVG(salary) BETWEEN 25000 AND 40000;

```


- `AVG(salary) AS average_salary` → دالة تجميعية بتحسب متوسط الرواتب.

- `GROUP BY dno` → التجميع حسب رقم القسم — كل قسم يبقى مجموعة، ويتحسب له متوسط منفصل.

- `HAVING AVG(salary) BETWEEN 25000 AND 40000;` → فلترة على نتيجة المتوسط نفسها بعد التجميع، شامل الطرفين زي ما شرحنا في BETWEEN.
## 15) Department With the Highest Average Salary


**الفكرة:** عايزين "أعلى" قيمة بس، وممنوع نستخدم Window Functions. الحل البسيط: احسب المتوسط لكل قسم، رتبهم تنازليًا، وهات أول صف بس.


```sql

SELECT d.dname, AVG(e.salary) AS average_salary

FROM employee e

JOIN department d ON e.dno = d.dnumber

GROUP BY d.dname

ORDER BY average_salary DESC

LIMIT 1;

```


- `JOIN department d ON e.dno = d.dnumber` → عملنا الـ JOIN الأول عشان نقدر نعرض اسم القسم `dname` مش بس رقمه.

- `GROUP BY d.dname` → تجميع الموظفين حسب اسم القسم اللي هما فيه، وحساب متوسط راتبهم.

- `ORDER BY average_salary DESC` → رتب الأقسام من الأعلى متوسط للأقل.

- `LIMIT 1;` → هات أول صف بس بعد الترتيب، وده اللي بيمثل "أعلى متوسط راتب" من غير ما نحتاج MAX() مع subquery أو Window Function.


---


## 16) Employees Who Work on Projects Controlled by Another Department


**الفكرة:** عايزين نقارن قيمتين جايين من مصدرين مختلفين بعد الـ JOIN: قسم الموظف نفسه، وقسم المشروع اللي بيشتغل عليه. لو مختلفين يبقى ده المطلوب.


```sql

SELECT

e.fname,

e.lname,

e.dno AS employee_department,

p.pname,

p.dnum AS project_department

FROM employee e

JOIN works_on w ON e.ssn = w.essn

JOIN project p ON w.pno = p.pnumber

WHERE e.dno <> p.dnum;

```


- `e.dno AS employee_department` → قسم الموظف نفسه (العمود dno في جدول employee).

- `p.dnum AS project_department` → القسم المسؤول عن المشروع (العمود dnum في جدول project).

- `JOIN works_on ... JOIN project ...` → نفس سلسلة الربط المعتادة عشان نوصل من الموظف للمشروع اللي شغال عليه.

- `WHERE e.dno <> p.dnum;` → `<>` معناها "لا يساوي". الشرط هنا بيقارن بين عمودين (مش عمود وقيمة ثابتة زي الأسئلة اللي فاتت)، وده معنى "Comparison between columns" المذكور في المفاهيم.


---


## 17) Employees Who Work More Than 10 Hours on Projects in Stafford


**الفكرة:** نفس نمط الربط الثلاثي (employee → works_on → project)، بس دلوقتي فيه شرطين مع بعض: مكان المشروع، وعدد الساعات.


```sql

SELECT e.fname, e.lname, p.pname, w.hours

FROM employee e

JOIN works_on w ON e.ssn = w.essn

JOIN project p ON w.pno = p.pnumber

WHERE p.plocation = 'Stafford'

AND w.hours > 10;

```


- `WHERE p.plocation = 'Stafford'` → فلترة على موقع المشروع (عمود موجود جوه جدول project).

- `AND w.hours > 10;` → وبالتوازي، الساعات المسجلة في works_on لازم تكون أكبر من 10. الشرطين لازم يتحققوا مع بعض بسبب AND.


---


## 18) Employees Who Have Dependents


**الفكرة:** عايزين بس أسماء الموظفين اللي ليهم على الأقل Dependent واحد، لكن من غير تكرار حتى لو عنده أكتر من واحد.


```sql

SELECT DISTINCT e.fname, e.lname

FROM employee e

JOIN dependent d ON e.ssn = d.essn;

```


- `JOIN dependent d ON e.ssn = d.essn;` → بيربط كل موظف بكل سجل معالة (dependent) بتاعه. لو عنده 3 معالين، هيطلع 3 صفوف مكررة لنفس الموظف قبل أي معالجة.

- `SELECT DISTINCT e.fname, e.lname` → كلمة `DISTINCT` بتشيل التكرار من النتيجة النهائية، فلو نفس الاسم اتكرر 3 مرات بسبب الـ JOIN، هيظهر مرة واحدة بس.


---


## 19) Employees Who Have the Same Salary as Another Employee (Self Join)


**الفكرة:** عايزين نقارن الجدول بنفسه — كل موظف مع كل موظف تاني، عشان نلاقي زوجين رواتبهم متطابقة. ده اسمه Self Join، وبيحتاج نديله للجدول اسمين مستعارين مختلفين.


```sql

SELECT DISTINCT e1.fname, e1.lname, e1.salary

FROM employee e1

JOIN employee e2

ON e1.salary = e2.salary

AND e1.ssn <> e2.ssn;

```


- `FROM employee e1 JOIN employee e2` → بنعامل جدول employee كأنه جدولين منفصلين (نسختين، e1 وe2)، عشان نقدر نقارن كل صف مع كل صف تاني في نفس الجدول.

- `ON e1.salary = e2.salary` → شرط التطابق الأساسي: نفس الراتب.

- `AND e1.ssn <> e2.ssn;` → شرط مهم جدًا: امنع الموظف إنه يتقارن بنفسه (لو e1 وe2 نفس الشخص هيبقى ليهم نفس الراتب أكيد، وده مش المطلوب). بنستخدم ssn (رقم فريد) للمقارنة بدل الاسم عشان الدقة.

- `SELECT DISTINCT ...` → بما إن كل موظف ممكن يتقابل مع أكتر من موظف تاني بنفس راتبه (لو فيه 3 ناس بنفس الراتب)، ممكن يتكرر ظهوره أكتر من مرة، فـ DISTINCT بتشيل أي تكرار في نتيجة العرض النهائية.


---


## 20) FINAL CHALLENGE — Department Project Report


**الفكرة:** التقرير ده بيجمع بيانات من مصدرين مختلفين تمامًا لكل قسم: (1) إحصائيات الموظفين (عددهم، رواتبهم)، و(2) إحصائيات المشاريع (عددها، ساعاتها). لو عملنا JOIN مباشر بين employee وproject/works_on في استعلام واحد، الأرقام هتتضاعف غلط (كل موظف هيتكرر مع كل مشروع). الحل: نحسب كل مجموعة إحصائيات لوحدها في subquery منفصلة، وبعدين نربطهم على مستوى القسم بس.


```sql

SELECT

d.dname AS department_name,

emp_stats.num_employees,

emp_stats.total_salary,

emp_stats.average_salary,

proj_stats.num_projects,

proj_stats.total_project_hours

FROM department d

LEFT JOIN (

SELECT dno,

COUNT(*) AS num_employees,

SUM(salary) AS total_salary,

AVG(salary) AS average_salary

FROM employee

GROUP BY dno

) emp_stats ON d.dnumber = emp_stats.dno

LEFT JOIN (

SELECT p.dnum,

COUNT(DISTINCT p.pnumber) AS num_projects,

SUM(w.hours) AS total_project_hours

FROM project p

LEFT JOIN works_on w ON p.pnumber = w.pno

GROUP BY p.dnum

) proj_stats ON d.dnumber = proj_stats.dnum

ORDER BY emp_stats.total_salary DESC;

```


- **Subquery الأولى (emp_stats):**

- `SELECT dno, COUNT(*) AS num_employees, SUM(salary) AS total_salary, AVG(salary) AS average_salary FROM employee GROUP BY dno` → استعلام مستقل بيحسب لكل قسم (`GROUP BY dno`): عدد الموظفين (`COUNT(*)`)، إجمالي رواتبهم (`SUM(salary)`)، ومتوسط راتبهم (`AVG(salary)`). ده بيتحسب من جدول employee بس، من غير أي تدخل من جداول المشاريع.

- النتيجة دي بتتعامل معاها زي أي جدول عادي، وبنديها اسم مستعار `emp_stats`.


- **Subquery الثانية (proj_stats):**

- `FROM project p LEFT JOIN works_on w ON p.pnumber = w.pno` → بنربط كل مشروع بسجلات ساعات العمل عليه (LEFT JOIN عشان لو مشروع مفيهوش حد شغال عليه لسه، يفضل يظهر بـ 0 ساعات بدل ما يتشال تمامًا).

- `COUNT(DISTINCT p.pnumber) AS num_projects` → لازم نستخدم DISTINCT هنا لأن نفس المشروع بيتكرر في النتيجة بعدد صفوف works_on بتاعته (بسبب الـ JOIN)، فلو عددنا من غير DISTINCT هنعد نفس المشروع أكتر من مرة.

- `SUM(w.hours) AS total_project_hours` → مجموع كل ساعات العمل المسجلة على مشاريع نفس القسم.

- `GROUP BY p.dnum` → التجميع حسب رقم القسم المسؤول عن المشروع (dnum)، مش رقم القسم اللي فيه الموظف.


- **الاستعلام الرئيسي:**

- `FROM department d` → نبدأ من جدول الأقسام عشان كل قسم يظهر مرة واحدة مضمونة في التقرير حتى لو معندوش موظفين أو مشاريع.

- `LEFT JOIN (...) emp_stats ON d.dnumber = emp_stats.dno` → نربط نتيجة الـ subquery الأولى بالقسم على رقم القسم. استخدمنا `LEFT JOIN` (مش `JOIN` عادي) عشان لو قسم ملوش موظفين، يفضل يظهر في التقرير بقيم NULL بدل ما يختفي تمامًا.

- `LEFT JOIN (...) proj_stats ON d.dnumber = proj_stats.dnum` → نفس الفكرة، نربط نتيجة إحصائيات المشاريع بالقسم.

- `ORDER BY emp_stats.total_salary DESC;` → في الآخر نرتب الأقسام حسب إجمالي الرواتب من الأكبر للأصغر، زي ما طلب السؤال بالظبط.


**ليه عملنا كده بالذات؟**

لو حاولنا نعمل استعلام واحد فيه:

```

FROM department

JOIN employee ...

JOIN project ...

JOIN works_on ...

```

كل صف موظف كان هيتقابل مع كل صف works_on/project تابع لنفس القسم، فلو القسم فيه 5 موظفين و3 مشاريع، هيطلعلك 15 صف بدل صف واحد للقسم، وأي SUM أو COUNT هتتضاعف غلط (Fan-out problem). عشان كده الحل الصح هو نجمّع كل جانب (الموظفين لوحدهم، والمشاريع لوحدها) في
