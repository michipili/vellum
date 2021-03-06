(cl:in-package #:vellum.column)

(prove:plan 2139)

(let* ((column (make-sparse-material-column))
       (iterator (make-iterator `(,column))))
  (iterate
    (for i from 0 below 256)
    (setf (iterator-at iterator 0) i)
    (move-iterator iterator 1))
  (finish-iterator iterator)
  (iterate
    (for i from 0 below 256)
    (prove:is (column-at column i) i))
  (setf iterator (make-iterator `(,column)))
  (iterate
    (for j from 255 downto 0)
    (setf (iterator-at iterator 0) j)
    (move-iterator iterator 1))
  (finish-iterator iterator)
  (iterate
    (for j from 255 downto 0)
    (for i from 0 below 256)
    (prove:is (column-at column i) j))
  (setf iterator (make-iterator `(,column)))
  (iterate
    (for j from 128 above 0)
    (setf (iterator-at iterator 0) j)
    (move-iterator iterator 1))
  (finish-iterator iterator)
  (iterate
    (for i from 0 below 128)
    (for j from 128 downto 0)
    (prove:is (column-at column i) j))
  (iterate
    (for i from 128 below 256)
    (for j from 127 downto 0)
    (prove:is (column-at column i) j)))

(let* ((column (make-sparse-material-column))
       (iterator (make-iterator `(,column))))
  (iterate
    (for i from 0 below 256)
    (setf (iterator-at iterator 0) i)
    (move-iterator iterator 1))
  (finish-iterator iterator)
  (truncate-to-length column 73)
  (prove:is (column-size column) 73)
  (iterate
    (for i from 0 below 73)
    (prove:is (column-at column i) i))
  (iterate
    (for i from 73 below 256)
    (prove:is (column-at column i) :null)))

(let* ((column (make-sparse-material-column))
       (iterator (make-iterator `(,column)))
       (not-deleted (make-hash-table)))
  (iterate
    (for i from 0 below 256)
    (setf (iterator-at iterator 0) i)
    (move-iterator iterator 1))
  (finish-iterator iterator)
  (let ((nulls (~> (iota 256)
                   (coerce 'vector)
                   shuffle
                   (take 50 _))))
    (iterate
      (for i in-vector nulls)
      (cl-ds:erase! column i))
    (iterate
      (for i in-vector nulls)
      (prove:is (column-at column i) :null)))
  (setf iterator (make-iterator `(,column)))
  (remove-nulls iterator)
  (iterate
    (for i from 0 below (- 256 50))
    (for content = (column-at column i))
    (setf (gethash content not-deleted) t)
    (prove:isnt content :null))
  (prove:is (hash-table-count not-deleted) (- 256 50))
  (let ((vector-data (cl-ds.alg:to-vector column)))
    (prove:is (length vector-data) (- 256 50))
    (iterate
      (for i from 0 below (- 256 50))
      (prove:is (aref vector-data i) (column-at column i)))))

(let* ((column1 (make-sparse-material-column))
       (column2 (make-sparse-material-column))
       (iterator (make-iterator `(,column1 ,column2))))
  (iterate
    (for i from 0 below 256)
    (for j from 512)
    (setf (iterator-at iterator 0) i)
    (setf (iterator-at iterator 1) j)
    (move-iterator iterator 1))
  (finish-iterator iterator)
  (iterate
    (for i from 0 below 256)
    (for j from 512)
    (prove:is (column-at column1 i) i)
    (prove:is (column-at column2 i) j))
  (cl-ds:erase! column1 50)
  (cl-ds:erase! column1 1)
  (cl-ds:erase! column1 5)
  (cl-ds:erase! column1 8)
  (cl-ds:erase! column2 1)
  (cl-ds:erase! column2 128)
  (cl-ds:erase! column2 5)
  (setf iterator (make-iterator `(,column1 ,column2)))
  (remove-nulls iterator)
  (prove:isnt (column-at column1 1) :null)
  (prove:isnt (column-at column1 4) :null)
  (prove:isnt (column-at column1 5) :null)
  (prove:is (column-at column1 6) :null)
  (prove:is (column-at column1 48) :null)
  (prove:isnt (column-at column2 1) :null)
  (prove:isnt (column-at column2 1) :null)
  (prove:isnt (column-at column2 4) :null)
  (prove:isnt (column-at column2 5) :null)
  (prove:is (column-at column2 126) :null))

(let* ((column1 (make-sparse-material-column))
       (column2 (make-sparse-material-column))
       (iterator (make-iterator `(,column1 ,column2))))
  (iterate
    (for i from 0 below 256)
    (for j from 512)
    (setf (iterator-at iterator 0) i)
    (setf (iterator-at iterator 1) j)
    (move-iterator iterator 1))
  (finish-iterator iterator)
  (setf iterator (make-iterator `(,column1 ,column2)))
  (iterate
    (for i from 0 below 128)
    (setf (iterator-at iterator 0) i)
    (move-iterator iterator 1))
  (iterate
    (for i from 128 below 256)
    (prove:is (iterator-at iterator 1) (+ i 512))
    (move-iterator iterator 1)))

(prove:finalize)
