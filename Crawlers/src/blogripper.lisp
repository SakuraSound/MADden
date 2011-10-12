(ql:quickload '(cl-ppcre drakma trivial-shell))

(defun blog-specific-article-matcher (basename)
  (cl-ppcre:create-scanner (concatenate 'string basename "\\d{4}/\\d{2}/\\d{2}/[\\w-]+")))

(defun blog-article-title-matcher ()
           (cl-ppcre:create-scanner "(?<team-name>[\\w]+).com/(?<date>\\d{4}/\\d{2}/\\d{2})/(?<article-name>[\\w-]+)"))

(defun blog-specific-next-page-matcher (basename)
  (cl-ppcre:create-scanner (concatenate 'string basename "page/\\d+")))

(defun blog-get-next-page (page-string matcher)
  (car (cl-ppcre:all-matches-as-strings matcher page-string)))
;;; get first page, extract article links, and next page links
;;; get next page, ...

(defparameter blog-urls (make-hash-table :test #'equal))
(defparameter bills-blog-urls (make-hash-table :test #'equal))

(defun traverse-blog (basename blog-urls-table)
  (declare (optimize debug))
  (let ((article-matcher (blog-specific-article-matcher basename))
        (next-page-matcher (blog-specific-next-page-matcher basename)))
    (loop with current-page = (drakma:http-request basename)
       with link-count = 0
       for page-number from 1
       for page-before-last = last-page
       for last-page = next-page
       for next-page = (blog-get-next-page current-page next-page-matcher)
       ;do (print current-page)
       do (loop for url in (delete-duplicates (cl-ppcre:all-matches-as-strings article-matcher current-page) :test #'string-equal)
             ;do (print url)
             do (incf link-count)
             do (push url (gethash basename blog-urls-table)))
       do (print next-page)
       do (setf current-page (drakma:http-request next-page))
       until (string-equal page-before-last next-page)
       finally (progn
                 (setf (gethash basename blog-urls-table) (delete-duplicates (gethash basename blog-urls-table) :test #'string-equal))
                 (format t "~&crawled ~D pages and found ~D links with ~D unique"
                         page-number link-count (length (gethash basename blog-urls-table)))))))

;; close but not exactly "http://blog.denverbroncos.com/"
;; "http://blog.patriots.com/" ;; did it twice already
(defparameter blog-url-list (delete-duplicates (list  "http://blog.newyorkjets.com/" "http://blogs.baltimoreravens.com/" "http://blogs.bengals.com/" "http://blogs.clevelandbrowns.com/" "http://blog.houstontexans.com/" "http://blogs.jaguars.com/" "http://blog.chargers.com/" "http://blog.philadelphiaeagles.com/" "http://blogs.detroitlions.com/" "http://blog.packers.com/" "http://blog.vikings.com/" "http://blog.neworleanssaints.com/" "http://blog.azcardinals.com/" "http://blog.stlouisrams.com/" "http://blog.49ers.com/" "http://blog.seahawks.com/" "http://blogs.buffalobills.com/" "http://blog.patriots.com/") :test #'string-equal))

(defun traverse-blogs-list (list-of-blogs)
  (loop for blog in list-of-blogs
      
     do (traverse-blog blog blog-urls))
  (with-open-file
      (stream "urls" :direction
              :output :if-exists
              :supersede :if-does-not-exist :create)
    (loop for key being the hash-keys of blog-urls
       using (hash-value value)
       with total-link-count = 0
       do (loop for url in value
             for (thing article-title) = (multiple-value-list (cl-ppcre:scan-to-strings (blog-article-title-matcher) url))
             do (incf total-link-count)
             do (format stream "~A~&  dir=b/~A~&  out=~A~A.html~&"
                        url
                        (aref article-title 0)
                        (substitute #\- #\/ (aref article-title 1))
                        (aref article-title 2)))
       finally (format t "~&total number of links is ~D~&" total-link-count)))
  (trivial-shell:shell-command "aria2c -j20 -s1 -i /home/morgan/blogs/crawlybitslisp/urls")
  )
