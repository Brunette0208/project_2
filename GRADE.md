Dear Student,

I'm happy to announce that you've managed to get **5** out of 8 points for this assignment.
<details><summary>You have already managed to pass 5 tests, so that is encouraging!</summary>&emsp;☑&nbsp;[1p]&nbsp;The&nbsp;model&nbsp;compiles<br>&emsp;☑&nbsp;[1p]&nbsp;Model&nbsp;should&nbsp;respect&nbsp;exclusions<br>&emsp;☑&nbsp;[1p]&nbsp;Model&nbsp;should&nbsp;assign&nbsp;required&nbsp;classes<br>&emsp;☑&nbsp;[1p]&nbsp;Model&nbsp;should&nbsp;not&nbsp;assign&nbsp;overlapping&nbsp;groups<br>&emsp;☑&nbsp;[1p]&nbsp;Model&nbsp;should&nbsp;calculate&nbsp;preference&nbsp;disappointment</details>

There still exist some issues that should be addressed before the deadline: **2025-02-21 08:00:00 CET (+0100)**. For further details, please refer to the following list:

<details><summary>[1p] Model should respect group limits &gt;&gt; enroll.mzn(data/trivial.dzn) &gt; groups have size limits and they should be respected...</summary>-&nbsp;group&nbsp;1&nbsp;has&nbsp;been&nbsp;assigned&nbsp;to&nbsp;3&nbsp;students,&nbsp;it&nbsp;is&nbsp;more&nbsp;than&nbsp;the&nbsp;group&nbsp;size&nbsp;limit&nbsp;2;<br>given&nbsp;'optimal'&nbsp;solution:<br>-&nbsp;objective&nbsp;=&nbsp;1;<br>-&nbsp;total_preference_disappointment&nbsp;=&nbsp;1;<br>-&nbsp;total_break_disappointment&nbsp;=&nbsp;0;<br>-&nbsp;assignment&nbsp;=&nbsp;[3..4,&nbsp;{1,6},&nbsp;{3,5},&nbsp;{1,4},&nbsp;1..1];</details>
<details><summary>[1p] Model should calculate break disappointment &gt;&gt; enroll.mzn(data/trivial_break_bis.dzn) &gt; model should correctly calculate disappointment related to long breaks...</summary>-&nbsp;total&nbsp;break&nbsp;disappointment&nbsp;should&nbsp;equal&nbsp;0,&nbsp;instead&nbsp;got&nbsp;1;<br>given&nbsp;'optimal'&nbsp;solution:<br>-&nbsp;objective&nbsp;=&nbsp;1;<br>-&nbsp;total_preference_disappointment&nbsp;=&nbsp;0;<br>-&nbsp;total_break_disappointment&nbsp;=&nbsp;1;<br>-&nbsp;assignment&nbsp;=&nbsp;[1..4];</details>
<details><summary>[1p] Model should calculate objective &gt;&gt; enroll.mzn(data/trivial_break_bis.dzn) &gt; model should correctly calculate the objective value...</summary>-&nbsp;objective&nbsp;should&nbsp;equal&nbsp;0,&nbsp;instead&nbsp;got&nbsp;1;<br>given&nbsp;'optimal'&nbsp;solution:<br>-&nbsp;objective&nbsp;=&nbsp;1;<br>-&nbsp;total_preference_disappointment&nbsp;=&nbsp;0;<br>-&nbsp;total_break_disappointment&nbsp;=&nbsp;1;<br>-&nbsp;assignment&nbsp;=&nbsp;[1..4];</details>

-----------
I remain your faithful servant\
_Bobot_\
_February 11, AD 2025, 12:05:42 (UTC)_