(ql:quickload '(cl-ppcre drakma trivial-shell)) ;; requires quicklisp to run

(defun blog-specific-article-matcher (basename)
  "This function creates a cl-ppcre matcher to use and reuse.
Matches wordpress format articles, which are,
the basename of the website
are followed by a single forward slash /
then a 4 digit year followed by a slash /
then 2 digit month followed by a slash /
then 2 dgit day followed by a slash /
then the article name with words separated by dashes -
followed by a slash /"
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
  (declare (optimize speed))
  (let ((article-matcher (blog-specific-article-matcher basename))
        (next-page-matcher (blog-specific-next-page-matcher basename)))
    (loop with current-page = (drakma:http-request basename) ; get current page
       with link-count = 0 ; save link count for stats after
       for page-number from 1 ; start at page 1
       for page-before-last = last-page ; save page before last for loop detection, could also use a hash table
       for last-page = next-page 
       for next-page = (blog-get-next-page current-page next-page-matcher) ; get next page link from page
       do (loop for url in
               (delete-duplicates (cl-ppcre:all-matches-as-strings article-matcher current-page) ; get *unique* links from page
                                  :test #'string-equal)
             do (incf link-count)
             do (push url (gethash basename blog-urls-table))) ; put link to visit later in hashtable
       do (print next-page)
       do (setf current-page (drakma:http-request next-page))
       until (string-equal page-before-last next-page)
       finally (progn
                 (setf (gethash basename blog-urls-table) ; uniquify links in hash table
                       (delete-duplicates (gethash basename blog-urls-table) :test #'string-equal))
                 (format t "~&crawled ~D pages and found ~D links with ~D unique"
                         page-number link-count (length (gethash basename blog-urls-table)))))))

;; close but not exactly "http://blog.denverbroncos.com/"
;; "http://blog.patriots.com/" ;; did it twice already
;; these are all the blogs of the same format, that this ripper works with
(defparameter blog-url-list
  (delete-duplicates (list  "http://blog.newyorkjets.com/" "http://blogs.baltimoreravens.com/" "http://blogs.bengals.com/" "http://blogs.clevelandbrowns.com/" "http://blog.houstontexans.com/" "http://blogs.jaguars.com/" "http://blog.chargers.com/" "http://blog.philadelphiaeagles.com/" "http://blogs.detroitlions.com/" "http://blog.packers.com/" "http://blog.vikings.com/" "http://blog.neworleanssaints.com/" "http://blog.azcardinals.com/" "http://blog.stlouisrams.com/" "http://blog.49ers.com/" "http://blog.seahawks.com/" "http://blogs.buffalobills.com/" "http://blog.patriots.com/") :test #'string-equal))

(defun traverse-blogs-list (list-of-blogs)
  (loop for blog in list-of-blogs ; loop for each blog we have 
     do (traverse-blog blog blog-urls)) ; and traverse it, grabbing all it's urls
  (with-open-file ;; this is where we put the urls to visit later
      (stream "urls" :direction
              :output :if-exists
              :supersede :if-does-not-exist :create)
    (loop for key being the hash-keys of blog-urls 
       using (hash-value value)
       with total-link-count = 0
       do (loop for url in value
             for (thing article-title) = (multiple-value-list (cl-ppcre:scan-to-strings (blog-article-title-matcher) url))
             do (incf total-link-count)
             do (format stream "~A~&  dir=b/~A~&  out=~A~A.html~&" ; aria2 format strings
                        url
                        (aref article-title 0)
                        (substitute #\- #\/ (aref article-title 1))
                        (aref article-title 2)))
       finally (format t "~&total number of links is ~D~&" total-link-count)))
  (trivial-shell:shell-command "aria2c -j20 -s1 -i /home/morgan/blogs/crawlybitslisp/urls") ; spawn an aria2 process to grab in parallel.
  )
