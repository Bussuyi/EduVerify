;; EduVerify - Academic credential verification and degree authentication system
(define-map academic-credentials uint {
  institution: principal,
  degree-title: (string-utf8 64),
  field-of-study: (string-utf8 256),
  graduation-year: uint,
  student-identifier: (string-utf8 64),
  verified: bool
})

(define-map institution-records principal (list 100 uint))
(define-map academic-verifiers principal bool)
(define-data-var credential-id-sequence uint u0)

;; Error codes
(define-constant err-unauthorized-institution (err u800))
(define-constant err-unauthorized-verifier (err u801))
(define-constant err-credential-not-found (err u802))
(define-constant err-permission-denied (err u403))
(define-constant err-records-limit-exceeded (err u804))
(define-constant err-invalid-verifier-principal (err u805))
(define-constant err-invalid-degree-title (err u806))
(define-constant err-invalid-field-of-study (err u807))
(define-constant err-invalid-graduation-year (err u808))
(define-constant err-invalid-student-identifier (err u809))
(define-constant err-invalid-credential-id (err u810))

;; Registry administrator for academic verification
(define-constant registry-admin tx-sender)

;; Register academic verifier
(define-public (register-academic-verifier (verifier principal))
  (begin
    ;; Confirm sender is registry administrator
    (asserts! (is-eq tx-sender registry-admin) err-permission-denied)
    
    ;; Validate verifier principal
    (asserts! (not (is-eq verifier 'SP000000000000000000002Q6VF78)) err-invalid-verifier-principal)
    
    ;; Add verifier to registry
    (ok (map-set academic-verifiers verifier true))
  )
)

;; Issue academic credential
(define-public (issue-academic-credential 
  (degree-title (string-utf8 64)) 
  (field-of-study (string-utf8 256)) 
  (graduation-year uint) 
  (student-identifier (string-utf8 64)))
  (let
    ((credential-id (var-get credential-id-sequence))
     (institution tx-sender)
     (current-records (default-to (list) (map-get? institution-records institution))))
    
    ;; Validate input parameters
    (asserts! (> (len degree-title) u0) err-invalid-degree-title)
    (asserts! (> (len field-of-study) u0) err-invalid-field-of-study)
    (asserts! (> graduation-year u1900) err-invalid-graduation-year)
    (asserts! (> (len student-identifier) u0) err-invalid-student-identifier)
    
    ;; Check records capacity
    (asserts! (< (len current-records) u100) err-records-limit-exceeded)
    
    ;; Store credential information
    (map-set academic-credentials credential-id {
      institution: institution,
      degree-title: degree-title,
      field-of-study: field-of-study,
      graduation-year: graduation-year,
      student-identifier: student-identifier,
      verified: false
    })
    
    ;; Update institution records
    (let 
      ((updated-records (unwrap-panic (as-max-len? (concat (list credential-id) current-records) u100))))
      (map-set institution-records institution updated-records)
    )
    
    ;; Increment credential ID sequence
    (var-set credential-id-sequence (+ credential-id u1))
    
    (ok credential-id)))

;; Verify academic credential
(define-public (verify-academic-credential (credential-id uint))
  (begin
    ;; Validate credential ID
    (asserts! (< credential-id (var-get credential-id-sequence)) err-invalid-credential-id)
    
    (let
      ((credential (unwrap! (map-get? academic-credentials credential-id) err-credential-not-found)))
      
      ;; Check if sender is authorized verifier
      (asserts! (default-to false (map-get? academic-verifiers tx-sender)) err-unauthorized-verifier)
      
      ;; Update verification status
      (ok (map-set academic-credentials credential-id (merge credential {verified: true})))
    )
  )
)

;; Get academic credential details
(define-read-only (get-academic-credential (credential-id uint))
  (map-get? academic-credentials credential-id))

;; Get institution records
(define-read-only (get-institution-records (institution principal))
  (default-to (list) (map-get? institution-records institution)))

;; Check verifier authorization
(define-read-only (is-academic-verifier (address principal))
  (default-to false (map-get? academic-verifiers address)))