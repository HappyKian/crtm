  @error_codes
  IF ( KEYWORD_SET(Debug) ) THEN BEGIN
    MESSAGE, '--> Entered.', /INFORMATIONAL
    MsgSwitch = 0
  ENDIF ELSE BEGIN
    CATCH, Error_Status
    IF ( Error_Status NE 0 ) THEN BEGIN
      CATCH, /CANCEL
      MESSAGE, !ERROR_STATE.MSG, /CONTINUE
      IF (self.id NE -1) THEN NCDF_CLOSE, self.id
      RETURN
    ENDIF
    MsgSwitch = 1
  ENDELSE
