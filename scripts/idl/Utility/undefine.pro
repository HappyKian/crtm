;+
;
; NAME:
;       Undefine
;
; PURPOSE:
;       Procedure to undefine a variable
;
; CALLING SEQUENCE:
;       Undefine, variable
;
; INPUTS:
;       variable:   Variable to be undefined
;
; CREATION HISTORY:
;       Written by:     Paul van Delst, CIMSS/SSEC, 16-Sep-2005
;                       paul.vandelst@ssec.wisc.edu
;
;-
PRO Undefine, var
  varTmp = SIZE(TEMPORARY(var))
END
