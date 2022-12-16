## Common pattern

There are two main types of exam result that are often be queried here: PASSED and NOT PASSED.


## What could be optimized here?
Since we based on the mark to categorize passed and failed results, and mark is a number. With those given clues, we can partition the table into 2 ranges: [0 - 4] for failed results and [5 - 10] for passed results. So that we can directly select from the child table that we need and cut down the cost of filtering.