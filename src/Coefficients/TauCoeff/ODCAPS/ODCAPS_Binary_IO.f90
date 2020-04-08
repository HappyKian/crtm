!------------------------------------------------------------------------------
!M+
! NAME:
!       ODCAPS_Binary_IO
!
! PURPOSE:
!       Module containing routines to read and write Binary format
!       ODCAPS files.
!       
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       USE ODCAPS_Binary_IO
!
! MODULES:
!       Type_Kinds:            Module containing definitions for kinds
!                              of variable types.
!
!       File_Utility:          Module containing generic file utility routines
!
!       Message_Handler:         Module to define simple error codes and
!                              handle error conditions
!                              USEs: FILE_UTILITY module
!
!       Binary_File_Utility:   Module containing utility routines for "Binary" 
!                              format datafiles.
!                              USEs: TYPE_KINDS module
!                                    FILE_UTILITY module
!                                    Message_Handler module
!
!       ODCAPS_Define:       Module defining the ODCAPS data structure and
!                              containing routines to manipulate it.
!                              USEs: TYPE_KINDS module
!                                    FILE_UTILITY module
!                                    Message_Handler module
!
!       ODCAPS_ODAS_Binary_IO:    Module containing routines to read and write
!                                      ODCAPS_ODAS Binary format files.
!                                USEs: TYPE_KINDS module
!                                      FILE_UTILITY module
!                                      Message_Handler module
!                                      BINARY_FILE_UTILITY module
!                                      ODCAPS_ODAS_DEFINE module
!
!       ODCAPS_TraceGas_Binary_IO:    Module containing routines to read and write
!                                       ODCAPS_TraceGas Binary format files.
!                                USEs: TYPE_KINDS module
!                                      FILE_UTILITY module
!                                      Message_Handler module
!                                      BINARY_FILE_UTILITY module
!                                      ODCAPS_TRACEGAS_DEFINE module
!
!       ODCAPS_Subset_Binary_IO:     Module containing routines to read and write
!                                      ODCAPS_Subset Binary format files.
!                                USEs: TYPE_KINDS module
!                                      FILE_UTILITY module
!                                      Message_Handler module
!                                      BINARY_FILE_UTILITY module
!                                      ODCAPS_SUBSET_DEFINE module
!
!
! CONTAINS:
!       Inquire_ODCAPS_Binary: Function to inquire a Binary format
!                                ODCAPS file.
!
!       Read_ODCAPS_Binary:    Function to read a Binary format
!                                ODCAPS file.
!
!       Write_ODCAPS_Binary:   Function to write a Binary format
!                                ODCAPS file.
!
! INCLUDE FILES:
!       None.
!
! EXTERNALS:
!       None.
!
! COMMON BLOCKS:
!       None.
!
! FILES ACCESSED:
!       User specified Binary format ODCAPS data files for both
!       input and output.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 05-May-2006
!                       Yong.Chen@noaa.gov
!
!  Copyright (C) 2006 Yong Chen
!
!  This program is free software; you can redistribute it and/or
!  modify it under the terms of the GNU General Public License
!  as published by the Free Software Foundation; either Version 2
!  of the License, or (at your option) any later Version.
!
!  This program is distributed in the hope that it will be useful,
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!  GNU General Public License for more details.
!
!  You should have received a copy of the GNU General Public License
!  along with this program; if not, write to the Free Software
!  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
!M-
!------------------------------------------------------------------------------

MODULE ODCAPS_Binary_IO


  ! ----------
  ! Module use
  ! ----------

  USE Type_Kinds         , ONLY: Long, Double
  USE File_Utility       , ONLY: File_Open, File_Exists
  USE Message_Handler    , ONLY: SUCCESS, FAILURE, WARNING, INFORMATION, Display_Message
  USE Binary_File_Utility, ONLY: Open_Binary_File

  USE ODCAPS_Define

  USE ODCAPS_ODAS_Binary_IO
  USE ODCAPS_TraceGas_Binary_IO
  USE ODCAPS_Subset_Binary_IO
  
   
  ! -----------------------
  ! Disable implicit typing
  ! -----------------------

  IMPLICIT NONE


  ! ------------
  ! Visibilities
  ! ------------

  PRIVATE
  PUBLIC :: Inquire_ODCAPS_Binary
  PUBLIC :: Read_ODCAPS_Binary
  PUBLIC :: Write_ODCAPS_Binary


  ! -----------------
  ! Module parameters
  ! -----------------

  ! -- Module RCS Id string
  CHARACTER( * ), PRIVATE, PARAMETER :: MODULE_RCS_ID = &

  ! -- Keyword set value
  INTEGER, PRIVATE, PARAMETER :: UNSET = 0
  INTEGER, PRIVATE, PARAMETER :: SET = 1
  INTEGER, PRIVATE, PARAMETER :: SL = 20   ! Sensor Id


CONTAINS





!------------------------------------------------------------------------------
!S+
! NAME:
!       Inquire_ODCAPS_Binary
!
! PURPOSE:
!       Function to inquire a Binary format ODCAPS file.
!
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       Error_Status = Inquire_ODCAPS_Binary(   Filename,                    &  ! Input
!                                               Algorithm_ID        = Algorithm_ID,        &  ! Optional Output
!                                               n_Layers            = n_Layers,            &  ! Optional output
!                                  	        n_Channels          = n_Channels,	   &  ! Optional output 
!                                   	        n_Tunings           = n_Tunings,           &  ! Optional output 
!                                   	        n_F_Predictors      = n_F_Predictor,	   &  ! Optional output 
!			           	        n_RefProfile_Items  = n_RefProfile_Items,  &  ! Optional output 
!			           	        n_NONLTE_Predictors = n_NONLTE_Predictors, &  ! Optional output  
!                                   	        n_NONLTE_Channels   = n_NONLTE_Channels,   &  ! Optional output  
!                                   	        n_TraceGases        = n_TraceGases,	   &  ! Optional output  
!                                   	        n_Subsets           = n_Subsets,	   &  ! Optional output  
!                                               Release             = Release,             &  ! Optional output	 
!                                               Version             = Version,             &  ! Optional Output
!                                               Sensor_Id           = Sensor_Id       ,    &  ! Optional output
!                                               WMO_Satellite_Id    = WMO_Satellite_Id,    &  ! Optional output
!                                               WMO_Sensor_Id       = WMO_Sensor_Id   ,    &  ! Optional output
!                                               RCS_Id              = RCS_Id,	           &  ! Revision control
!                                               Message_Log         = Message_Log   )         ! Error messaging
!
! INPUT ARGUMENTS:
!       Filename:           Character string specifying the name of the binary
!                           ODCAPS data file to inquire.
!                           UNITS:      N/A
!                           TYPE:       CHARACTER( * )
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( IN )
!
! OPTIONAL INPUT ARGUMENTS:
!       Message_Log:        Character string specifying a filename in which any
!                           Messages will be logged. If not specified, or if an
!                           error occurs opening the log file, the default action
!                           is to output Messages to standard output.
!                           UNITS:      N/A
!                           TYPE:       CHARACTER( * )
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( IN ), OPTIONAL
!
! OUTPUT ARGUMENTS:
!       None.
!
! OPTIONAL OUTPUT ARGUMENTS:
!       Algorithm_ID:       The ODCAPS data Algorithm_ID. Used to determine
!                           which algorithm to be used.
!                           UNITS:      N/A
!                           TYPE:       INTEGER
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: OPTIONAL, INTENT(OUT)
!
!       n_Layers:	    Maximum layers for the coefficients.		   
!       		    "Ilayers" dimension.				   
!       		    UNITS:	N/A					   
!       		    TYPE:	INTEGER( Long ) 			   
!       		    DIMENSION:  Scalar  				   
!
!       n_Channels:	    Total number of spectral channels.  		   
!       		    "L" dimension.					   
!       		    UNITS:	N/A					   
!       		    TYPE:	INTEGER( Long ) 			   
!       		    DIMENSION:  Scalar  				   
!
!       n_Tunings:	    Number of tuning multipliers for the gases  	   
!       		    "J" dimension.					   
!       		    UNITS:	N/A					   
!       		    TYPE:	INTEGER( Long ) 			   
!       		    DIMENSION:  Scalar  				   
!
!       n_F_Predictors:     Number of predictors used in the			   
!       		    thermal "F" factor coefs.				   
!       		    "MF" dimension.					   
!       		    UNITS:	N/A					   
!       		    TYPE:	INTEGER( Long ) 			   
!       		    DIMENSION:  Scalar  				   
!
!       n_RefProfile_Items: Number of item in the reference profile.		   
!       		    "N" dimension.					   
!       		    UNITS:	N/A					   
!       		    TYPE:	INTEGER( Long ) 			   
!       		    DIMENSION:  Scalar  				   
!
!       n_NONLTE_Predictors:The number of predictors for the non-LTE.		   
!       		    "MNON" dimension.					   
!       		    UNITS:	N/A					   
!       		    TYPE:	INTEGER( Long ) 			   
!       		    DIMENSION:  Scalar  				   
!
!       n_NONLTE_Channels:  The number of channels for the non-LTE.		   
!       		    "MChannels" dimension.				   
!       		    UNITS:	N/A					   
!       		    TYPE:	INTEGER( Long ) 			   
!       		    DIMENSION:  Scalar  				   
!
!       n_TraceGases:	    The number of trace gases.  			   
!       		    "KTraces" dimension.				   
!       		    UNITS:	N/A					   
!       		    TYPE:	INTEGER( Long ) 			   
!       		    DIMENSION:  Scalar  				   
!
!       n_Subsets:	    The number of subset for the gas absorption coeffs.    
!       		    "K" dimension.					   
!       		    UNITS:	N/A					   
!       		    TYPE:	INTEGER( Long ) 			   
!       		    DIMENSION:  Scalar  				   
!
!       Release:            The ODCAPS data/file release number. Used to check
!                           for data/software mismatch.
!                           UNITS:      N/A
!                           TYPE:       INTEGER
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( OUT ), OPTIONAL
!
!       Version:            The ODCAPS data/file version number. Used for
!                           purposes only in identifying the dataset for
!                           a particular release.
!                           UNITS:      N/A
!                           TYPE:       INTEGER
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( OUT ), OPTIONAL
!
!       Sensor_Id:          Character string sensor/platform identifier.
!                           UNITS:      N/A
!                           TYPE:       CHARACTER(*)
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT(OUT), OPTIONAL
!
!       WMO_Satellite_Id:   The WMO code used to identify satellite platforms.
!                           UNITS:      N/A
!                           TYPE:       INTEGER
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT(OUT), OPTIONAL
!
!       WMO_Sensor_Id:      The WMO code used to identify sensors.
!                           UNITS:      N/A
!                           TYPE:       INTEGER
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT(OUT), OPTIONAL
!
!       RCS_Id:             Character string containing the Revision Control
!                           System Id field for the module.
!                           UNITS:      N/A
!                           TYPE:       CHARACTER( * )
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( OUT ), OPTIONAL
!
! FUNCTION RESULT:
!       Error_Status: The return value is an integer defining the error status.
!                     The error codes are defined in the Message_Handler module.
!                     If == SUCCESS the Binary file inquiry was successful
!                        == FAILURE an unrecoverable error occurred.
!                     UNITS:      N/A
!                     TYPE:       INTEGER
!                     DIMENSION:  Scalar
!
! CALLS:
!       Open_Binary_File:        Function to open Binary format
!                                data files.
!                                SOURCE: BINARY_FILE_UTILITY module
!
!       Display_Message:         Subroutine to output Messages
!                                SOURCE: Message_Handler module
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 05-May-2006
!                       Yong.Chen@noaa.gov
!S-
!------------------------------------------------------------------------------
  FUNCTION Inquire_ODCAPS_Binary( Filename,           &  ! Input
                                    Algorithm_ID,       &  ! Optional Output
                                    n_Layers,           &  ! Optional output
                                    n_Channels,         &  ! Optional output
                                    n_Tunings,  	&  ! Optional output 
			            n_F_Predictors,	&  ! Optional output
			            n_RefProfile_Items, &  ! Optional output
			            n_NONLTE_Predictors,&  ! Optional output
			            n_NONLTE_Channels,  &  ! Optional output
			            n_TraceGases,	&  ! Optional output
			            n_Subsets,  	&  ! Optional output
                                    Release,            &  ! Optional Output
                                    Version,            &  ! Optional Output
                                    RCS_Id,             &  ! Revision control
                                    Sensor_Id       ,   &  ! Optional Output
                                    WMO_Satellite_Id,   &  ! Optional Output
                                    WMO_Sensor_Id   ,   &  ! Optional Output
                                    Message_Log )       &  ! Error messaging
                                  RESULT ( Error_Status )



    !#--------------------------------------------------------------------------#
    !#                          -- TYPE DECLARATIONS --                         #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Input
    CHARACTER( * ),           INTENT( IN )  :: Filename

    ! -- Optional output
    INTEGER,        OPTIONAL, INTENT( OUT ) :: Algorithm_ID 
    INTEGER,        OPTIONAL, INTENT( OUT ) :: n_Layers
    INTEGER,        OPTIONAL, INTENT( OUT ) :: n_Channels
    INTEGER,        OPTIONAL, INTENT( OUT ) :: n_Tunings 
    INTEGER,        OPTIONAL, INTENT( OUT ) :: n_F_Predictors
    INTEGER,        OPTIONAL, INTENT( OUT ) :: n_RefProfile_Items
    INTEGER,        OPTIONAL, INTENT( OUT ) :: n_NONLTE_Predictors
    INTEGER,        OPTIONAL, INTENT( OUT ) :: n_NONLTE_Channels
    INTEGER,        OPTIONAL, INTENT( OUT ) :: n_TraceGases
    INTEGER,        OPTIONAL, INTENT( OUT ) :: n_Subsets 
    
    INTEGER,        OPTIONAL, INTENT( OUT ) :: Release
    INTEGER,        OPTIONAL, INTENT( OUT ) :: Version
    CHARACTER(*),   OPTIONAL, INTENT( OUT ) :: Sensor_Id       
    INTEGER     ,   OPTIONAL, INTENT( OUT ) :: WMO_Satellite_Id
    INTEGER     ,   OPTIONAL, INTENT( OUT ) :: WMO_Sensor_Id   

    ! -- Revision control
    CHARACTER( * ), OPTIONAL, INTENT( OUT ) :: RCS_Id

    ! -- Error Message log file
    CHARACTER( * ), OPTIONAL, INTENT( IN )  :: Message_Log


    ! ---------------
    ! Function result
    ! ---------------

    INTEGER :: Error_Status


    ! -------------------
    ! Function parameters
    ! -------------------

    CHARACTER( * ), PARAMETER :: ROUTINE_NAME = 'Inquire_ODCAPS_Binary'


    ! ------------------
    ! Function variables
    ! ------------------

    CHARACTER( 256 ) :: Message
    INTEGER :: IO_Status
    INTEGER :: FileID
    INTEGER( Long ) :: File_Algorithm_ID
    INTEGER( Long ) :: File_Release
    INTEGER( Long ) :: File_Version
    INTEGER( Long ) :: File_n_Layers
    INTEGER( Long ) :: File_n_Channels
    INTEGER( Long ) :: File_n_Tunings 
    INTEGER( Long ) :: File_n_F_Predictors 
    INTEGER( Long ) :: File_n_RefProfile_Items 
    INTEGER( Long ) :: File_n_NONLTE_Predictors 
    INTEGER( Long ) :: File_n_NONLTE_Channels 
    INTEGER( Long ) :: File_n_TraceGases 
    INTEGER( Long ) :: File_n_Subsets 
    CHARACTER(SL)   :: File_Sensor_Id       
    INTEGER( Long ) :: File_WMO_Satellite_Id
    INTEGER( Long ) :: File_WMO_Sensor_Id     

    !#--------------------------------------------------------------------------#
    !#                  -- DEFINE A SUCCESSFUL EXIT STATUS --                   #
    !#--------------------------------------------------------------------------#

    Error_Status = SUCCESS


    ! -----------------------------------
    ! Set the RCS Id argument if supplied
    ! -----------------------------------

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF



    !#--------------------------------------------------------------------------#
    !#             -- OPEN THE BINARY FORMAT ODCAPS DATA FILE --              #
    !#--------------------------------------------------------------------------#

    Error_Status = Open_Binary_File( TRIM( Filename ), &
                                     FileID,   &
                                     Message_Log = Message_Log )

    IF ( Error_Status /= SUCCESS ) THEN
      CALL Display_Message( ROUTINE_NAME, &
                            'Error opening ODCAPS file '//TRIM( Filename ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#                      -- READ THE "FILE HEADER" --                        #
    !#--------------------------------------------------------------------------#

    ! ------------------------------------
    ! Read the Release/Version information
    ! ------------------------------------

    READ( FileID, IOSTAT = IO_Status ) File_Release, &
                                       File_Version

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading ODCAPS file Release/Version values from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    ! ------------------------------------
    ! Read the Algorithm_ID  information
    ! ------------------------------------
    READ( FileID, IOSTAT = IO_Status ) File_Algorithm_ID 
    
    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading ODCAPS file Algorithm ID value from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    ! -------------------
    ! Read the dimensions
    ! -------------------

    READ( FileID, IOSTAT = IO_Status )File_n_Layers,           &
                                      File_n_Channels,         &
                                      File_n_Tunings,          & 
                                      File_n_F_Predictors,     & 
                                      File_n_RefProfile_Items, & 
                                      File_n_NONLTE_Predictors,& 
                                      File_n_NONLTE_Channels,  & 
                                      File_n_TraceGases,       &
                                      File_n_Subsets 
    
    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading data dimensions from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    ! Read the sensor ids
    ! -------------------
    READ( FileID, IOSTAT=IO_Status ) File_Sensor_Id       , &
                                     File_WMO_Satellite_Id, &
                                     File_WMO_Sensor_Id    
    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading sensor information from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF
 
    !#--------------------------------------------------------------------------#
    !#                          -- CLOSE THE FILE --                            #
    !#--------------------------------------------------------------------------#

    CLOSE( FileID, STATUS = 'KEEP', &
                   IOSTAT = IO_Status )

    IF ( IO_Status /= 0 ) THEN
      WRITE( Message, '( "Error closing ", a, ". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            WARNING, &
                            Message_Log = Message_Log )
    END IF



    !#--------------------------------------------------------------------------#
    !#                    -- ASSIGN THE RETURN ARGUMENTS --                     #
    !#--------------------------------------------------------------------------#

    ! ----------
    ! Dimensions
    ! ----------
    IF ( PRESENT( Algorithm_ID ) ) THEN
      Algorithm_ID  = File_Algorithm_ID 
    END IF

    IF ( PRESENT( n_Layers ) ) THEN
      n_Layers  = File_n_Layers 
    END IF

    IF ( PRESENT( n_Channels ) ) THEN
      n_Channels = File_n_Channels
    END IF

    IF ( PRESENT( n_Tunings ) ) THEN
      n_Tunings = File_n_Tunings 
    END IF

    IF ( PRESENT( n_F_Predictors  ) ) THEN
      n_F_Predictors = File_n_F_Predictors 
    END IF

    IF ( PRESENT( n_RefProfile_Items ) ) THEN
      n_RefProfile_Items = File_n_RefProfile_Items 
    END IF

    IF ( PRESENT( n_NONLTE_Predictors ) ) THEN
      n_NONLTE_Predictors = File_n_NONLTE_Predictors 
    END IF

    IF ( PRESENT( n_NONLTE_Channels ) ) THEN
      n_NONLTE_Channels = File_n_NONLTE_Channels 
    END IF

    IF ( PRESENT( n_TraceGases ) ) THEN
      n_TraceGases = File_n_TraceGases  
    END IF

    IF ( PRESENT( n_Subsets  ) ) THEN
      n_Subsets = File_n_Subsets 
    END IF
    
    ! --------------
    ! Ancillary info
    ! --------------

    IF ( PRESENT( Release ) ) THEN
      Release = File_Release
    END IF


    IF ( PRESENT( Version ) ) THEN
      Version = File_Version
    END IF

    ! Sensor ids
    IF ( PRESENT(Sensor_Id       ) ) Sensor_Id        = File_Sensor_Id(1:MIN(LEN(Sensor_Id),LEN_TRIM(File_Sensor_Id)))
    IF ( PRESENT(WMO_Satellite_Id) ) WMO_Satellite_Id = File_WMO_Satellite_Id
    IF ( PRESENT(WMO_Sensor_Id   ) ) WMO_Sensor_Id    = File_WMO_Sensor_Id   

  END FUNCTION Inquire_ODCAPS_Binary


!------------------------------------------------------------------------------
!S+
! NAME:
!       Read_ODCAPS_Binary
!
! PURPOSE:
!       Function to read Binary format ODCAPS files.
!
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       Error_Status = Read_ODCAPS_Binary( Filename,                              &  ! Input
!                                            ODCAPS,                              &  ! Output
!                                            Quiet             = Quiet,             &  ! Optional input
!                                            Process_ID        = Process_ID,        &  ! Optional input
!                                            Output_Process_ID = Output_Process_ID, &  ! Optional input
!                                            RCS_Id            = RCS_Id,            &  ! Revision control
!                                            Message_Log       = Message_Log        )  ! Error messaging
!
! INPUT ARGUMENTS:
!       Filename:           Character string specifying the name of the binary
!                           format ODCAPS data file to read.
!                           UNITS:      N/A
!                           TYPE:       CHARACTER( * )
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( IN )
!
! OPTIONAL INPUT ARGUMENTS:
!       Quiet:              Set this argument to suppress INFORMATION messages
!                           being printed to standard output (or the message
!                           log file if the Message_Log optional argument is
!                           used.) By default, INFORMATION messages are printed.
!                           If QUIET = 0, INFORMATION messages are OUTPUT.
!                              QUIET = 1, INFORMATION messages are SUPPRESSED.
!                           UNITS:      N/A
!                           TYPE:       Integer
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( IN ), OPTIONAL
!
!       Process_ID:         Set this argument to the MPI process ID that this
!                           function call is running under. This value is used
!                           solely for controlling INFORMATIOn message output.
!                           If MPI is not being used, ignore this argument.
!                           This argument is ignored if the Quiet argument is set.
!                           UNITS:      N/A
!                           TYPE:       Integer
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( IN ), OPTIONAL
!
!       Output_Process_ID:  Set this argument to the MPI process ID in which
!                           all INFORMATION messages are to be output. If
!                           the passed Process_ID value agrees with this value
!                           the INFORMATION messages are output. 
!                           This argument is ignored if the Quiet argument
!                           is set.
!                           UNITS:      N/A
!                           TYPE:       Integer
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( IN ), OPTIONAL
!
!       Message_Log:        Character string specifying a filename in which any
!                           Messages will be logged. If not specified, or if an
!                           error occurs opening the log file, the default action
!                           is to output Messages to standard output.
!                           UNITS:      N/A
!                           TYPE:       CHARACTER( * )
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( IN ), OPTIONAL
!
! OUTPUT ARGUMENTS:
!       ODCAPS:             Structure containing the transmittance coefficient data
!                           read from the file.
!                           UNITS:      N/A
!                           TYPE:       ODCAPS_type
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( IN OUT )
!
! OPTIONAL OUTPUT ARGUMENTS:
!       RCS_Id:             Character string containing the Revision Control
!                           System Id field for the module.
!                           UNITS:      N/A
!                           TYPE:       CHARACTER( * )
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: OPTIONAL, INTENT( OUT )
!
! FUNCTION RESULT:
!       Error_Status:       The return value is an integer defining the error status.
!                           The error codes are defined in the Message_Handler module.
!                           If == SUCCESS the Binary file read was successful
!                              == FAILURE an unrecoverable read error occurred.
!                           UNITS:      N/A
!                           TYPE:       INTEGER
!                           DIMENSION:  Scalar
!
! CALLS:
!       Open_Binary_File:        Function to open Binary format
!                                data files.
!                                SOURCE: BINARY_FILE_UTILITY module
!
!       CheckRelease_ODCAPS:  Function to check the Release value of
!                                the ODCAPS data.
!                                SOURCE: ODCAPS_DEFINE module
!
!       Allocate_ODCAPS:       Function to allocate the pointer members
!                                of the ODCAPS structure.
!                                SOURCE: ODCAPS_DEFINE module
!
!       Count_ODCAPS_Sensors:  Subroutine to count the number of
!                                different satellite/sensors in the
!                                ODCAPS structure and set the
!                                n_Sensors field.
!                                SOURCE: ODCAPS_DEFINE module
!
!       Info_ODCAPS:        Subroutine to return a string containing
!                                version and dimension information about
!                                a ODCAPS data structure.
!                                SOURCE: ODCAPS_DEFINE module
!
!       Display_Message:         Subroutine to output Messages
!                                SOURCE: Message_Handler module
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
! COMMENTS:
!       Note the INTENT on the output ODCAPS argument is IN OUT rather than
!       just OUT. This is necessary because the argument may be defined upon
!       input. To prevent memory leaks, the IN OUT INTENT is a must.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 05-May-2006
!                       Yong.Chen@noaa.gov
!S-
!------------------------------------------------------------------------------
  FUNCTION Read_ODCAPS_Binary( Filename,          &  ! Input
                                 ODCAPS,          &  ! Output
                                 Quiet,             &  ! Optional input
                                 Process_ID,        &  ! Optional input
                                 Output_Process_ID, &  ! Optional input
                                 RCS_Id,            &  ! Revision control
                                 Message_Log )      &  ! Error messaging
                               RESULT ( Error_Status )



    !#--------------------------------------------------------------------------#
    !#                          -- TYPE DECLARATIONS --                         #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Input
    CHARACTER( * ),           INTENT( IN )     :: Filename

    ! -- Output
    TYPE( ODCAPS_type ),    INTENT( IN OUT ) :: ODCAPS

    ! -- Optional input
    INTEGER,        OPTIONAL, INTENT( IN )     :: Quiet
    INTEGER,        OPTIONAL, INTENT( IN )     :: Process_ID
    INTEGER,        OPTIONAL, INTENT( IN )     :: Output_Process_ID

    ! -- Revision control
    CHARACTER( * ), OPTIONAL, INTENT( OUT )    :: RCS_Id

    ! -- Error message log file
    CHARACTER( * ), OPTIONAL, INTENT( IN )     :: Message_Log


    ! ---------------
    ! Function result
    ! ---------------

    INTEGER :: Error_Status


    ! -------------------
    ! Function parameters
    ! -------------------

    CHARACTER( * ), PARAMETER :: ROUTINE_NAME = 'Read_ODCAPS_Binary'


    ! ------------------
    ! Function variables
    ! ------------------

    CHARACTER( 256 ) :: Message
    LOGICAL :: Noisy
    INTEGER :: IO_Status
    CHARACTER( 128 ) :: Process_ID_Tag
    INTEGER :: Destroy_Status
    INTEGER :: FileID
    INTEGER( Long ) :: n_Layers 	    
    INTEGER( Long ) :: n_Channels	    
    INTEGER( Long ) :: n_Tunings 	    
    INTEGER( Long ) :: n_F_Predictors 	    
    INTEGER( Long ) :: n_RefProfile_Items   
    INTEGER( Long ) :: n_NONLTE_Predictors  
    INTEGER( Long ) :: n_NONLTE_Channels    
    INTEGER( Long ) :: n_TraceGases 	    
    INTEGER( Long ) :: n_Subsets 	    
   


    !#--------------------------------------------------------------------------#
    !#                     -- INITIALISE THE ERROR STATUS --                    #
    !#--------------------------------------------------------------------------#

    Error_Status = SUCCESS



    !#--------------------------------------------------------------------------#
    !#                -- CHECK/SET OPTIONAL KEYWORD ARGUMENTS --                #
    !#--------------------------------------------------------------------------#

    ! -------------------
    ! Info message output
    ! -------------------

    ! -- Output informational messages....
    Noisy = .TRUE.

    ! -- ....unless....
    IF ( PRESENT( Quiet ) ) THEN
      ! -- ....the QUIET keyword is set.
      IF ( Quiet == SET ) Noisy = .FALSE.
    ELSE
      ! -- ....the Process_ID is not selected for output
      IF ( PRESENT( Process_ID ) .AND. PRESENT( Output_Process_ID ) ) THEN
        IF ( Process_ID /= Output_Process_ID ) Noisy = .FALSE.
      END IF
    END IF


    ! -----------------------------------
    ! Create a process ID message tag for
    ! WARNING and FAILURE messages
    ! -----------------------------------

    IF ( PRESENT( Process_ID ) ) THEN
      WRITE( Process_ID_Tag, '( ";  MPI Prcess ID: ", i5 )' ) Process_ID
    ELSE
      Process_ID_Tag = ' '
    END IF


    ! -------------------
    ! Module version info
    ! -------------------

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF


    !#--------------------------------------------------------------------------#
    !#                            -- CHECK INPUT --                             #
    !#--------------------------------------------------------------------------#

    ! --------------------------
    ! Check that the file exists
    ! --------------------------

    IF ( .NOT. File_Exists( TRIM( Filename ) ) ) THEN
      Message = 'File '//TRIM( Filename )//' not found.'
      Error_Status = FAILURE
      CALL Display_Message( ROUTINE_NAME, &
                          TRIM( Message ), &
                          Error_Status, &
                          Message_Log = Message_Log )
      Destroy_Status = Destroy_ODCAPS(ODCAPS, &
                                              Message_Log = Message_Log )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                    -- OPEN THE ODCAPS DATA FILE --                     #
    !#--------------------------------------------------------------------------#

    Error_Status = Open_Binary_File( TRIM( Filename ), &
                                     FileID,   &
                                     Message_Log = Message_Log )

    IF ( Error_Status /= SUCCESS ) THEN
      CALL Display_Message( ROUTINE_NAME, &
                            'Error opening '//TRIM( Filename )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#                      -- READ THE "FILE HEADER" --                        #
    !#--------------------------------------------------------------------------#

    ! ------------------------------------
    ! Read the Release/Version information
    ! ------------------------------------

    READ( FileID, IOSTAT = IO_Status ) ODCAPS%Release, &
                                       ODCAPS%Version

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading ODCAPS file Release/Version values from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF


    ! -----------------
    ! Check the release
    ! -----------------

    Error_Status = CheckRelease_ODCAPS( ODCAPS, Message_Log = Message_Log )

    IF ( Error_Status /= SUCCESS ) THEN
      CALL Display_Message( ROUTINE_NAME, &
                            'ODCAPS Release check failed for '//TRIM( Filename ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    ! Read the Algorithm_ID
    READ( FileID, IOSTAT = IO_Status ) ODCAPS%Algorithm  

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading Algorithm ID from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    ! Check the algorithm id
    Error_Status = CheckAlgorithm_ODCAPS( ODCAPS,Message_Log=Message_Log )
    IF (  Error_Status /= SUCCESS ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "ODAS Algorithm check failed for ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    ! -------------------
    ! Read the dimensions
    ! -------------------

    READ( FileID, IOSTAT = IO_Status ) n_Layers,           &
                                       n_Channels,	   &
                                       n_Tunings,	   & 
                                       n_F_Predictors,     & 
                                       n_RefProfile_Items, & 
                                       n_NONLTE_Predictors,& 
                                       n_NONLTE_Channels,  & 
                                       n_TraceGases,	   &
                                       n_Subsets 

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading data dimensions from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                  -- ALLOCATE THE ODCAPS STRUCTURE --                   #
    !#--------------------------------------------------------------------------#

    Error_Status = Allocate_ODCAPS( n_Layers,	          & 
                                      n_Channels,	  & 
                                      n_Tunings,	  & 
                                      n_F_Predictors,	  & 
                                      n_RefProfile_Items, & 
                                      n_NONLTE_Predictors,& 
                                      n_NONLTE_Channels,  & 
                                      n_TraceGases,	  & 
                                      n_Subsets,	  &  
                                      ODCAPS,           &
                                      Message_Log = Message_Log )

    IF ( Error_Status /= SUCCESS ) THEN
      CALL Display_Message( ROUTINE_NAME,    &
                            'Error occurred allocating ODCAPS structure.'//&
                            TRIM( Process_ID_Tag ), &
                            Error_Status,    &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

 
    !#--------------------------------------------------------------------------#
    !#                       -- READ THE SENSOR ID DATA --                      #
    !#--------------------------------------------------------------------------#

    READ( FileID, IOSTAT = IO_Status ) ODCAPS%Sensor_id, &
                                       ODCAPS%WMO_Satellite_ID, &
                                       ODCAPS%WMO_Sensor_ID, &
                                       ODCAPS%Sensor_Type
 
    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading sensor ID data from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    !#--------------------------------------------------------------------------#
    !#                       -- READ THE CHANNEL INDEX DATA --                      #
    !#--------------------------------------------------------------------------#

    READ( FileID, IOSTAT = IO_Status ) ODCAPS%Sensor_Channel,             &
                                       ODCAPS%Channel_Subset_Index,      &
                                       ODCAPS%Channel_Subset_Position,   &
                                       ODCAPS%Channel_H2O_OPTRAN,        &
                                       ODCAPS%Channel_CO2_Perturbation , &
                                       ODCAPS%Channel_SO2_Perturbation , &
                                       ODCAPS%Channel_HNO3_Perturbation, &
                                       ODCAPS%Channel_N2O_Perturbation,  &
                                       ODCAPS%Channel_NON_LTE 
 
    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading Channel Index data from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                      -- READ THE STANDARD LEVEL PRESSURE DATA --         #
    !#--------------------------------------------------------------------------#

    READ( FileID, IOSTAT = IO_Status ) ODCAPS%Standard_Level_Pressure 

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading Standard level pressure data from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#      -- READ THE Fix_Gases,Down_F_Factor,Tuning_Multiple DATA --         #
    !#--------------------------------------------------------------------------#

    READ( FileID, IOSTAT = IO_Status ) ODCAPS%Fix_Gases_Adjustment, &
                                       ODCAPS%Down_F_Factor, &
                                       ODCAPS%Tuning_Multiple

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading Fix_Gases_Adjustment data from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#                       -- READ THE REFERENCE PROFIEL DATA --                       #
    !#--------------------------------------------------------------------------#

    READ( FileID, IOSTAT = IO_Status ) ODCAPS%Ref_Profile_Data

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading reference profile from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                     -- READ THE NON-LTE COEFFICIENTS --                  #
    !#--------------------------------------------------------------------------#

    READ( FileID, IOSTAT = IO_Status ) ODCAPS%Non_LTE_Coeff 

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error reading non-LTE coefficients from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                -- READ THE WATER VAPOR OPTRAN COEFFICIENTS DATA--        #
    !#--------------------------------------------------------------------------#

    ! ---------------------
    ! Get the data filename
    ! ---------------------
 
    !INQUIRE( UNIT = FileID, NAME = Filename )

    ! ---------------------------------------------
    ! Read the water vapor optran coefficients data 
    ! ---------------------------------------------

    Error_Status = Read_ODCAPS_ODAS_Binary(Filename, &
                                                ODCAPS%ODCAPS_ODAS, &
                                                No_File_Close = SET, &
                                                Message_Log = Message_Log )

    IF ( Error_Status /= SUCCESS ) THEN
      WRITE( Message, '( "Error reading water OPTRAN absorption coefficients from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    !#--------------------------------------------------------------------------#
    !#                          -- READ THE ODCAPS_TraceGas DATA --                       #
    !#--------------------------------------------------------------------------#

    IF ( n_TraceGases > 0 ) THEN


      ! ---------------------
      ! Get the data filename
      ! ---------------------

      !INQUIRE( UNIT = FileID, NAME = Filename )


      ! -------------------
      ! Read the ODCAPS_TraceGas data
      ! -------------------

      Error_Status = Read_ODCAPS_TraceGas_Binary( Filename, &
                                             ODCAPS%ODCAPS_TraceGas, &
                                             No_File_Close = SET, &
                                             Message_Log = Message_Log )

      IF ( Error_Status /= SUCCESS ) THEN
        WRITE( Message, '( "Error reading ODCAPS_TraceGas coefficients from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
        CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
        CLOSE( FileID )
        RETURN

      END IF

    END IF


    !#--------------------------------------------------------------------------#
    !#                          -- READ THE ODCAPS_Subset DATA --                       #
    !#--------------------------------------------------------------------------#

    IF ( n_Subsets > 0 ) THEN


      ! ---------------------
      ! Get the data filename
      ! ---------------------

      !INQUIRE( UNIT = FileID, NAME = Filename )


      ! -------------------
      ! Read the ODCAPS_TraceGas data
      ! -------------------

      Error_Status = Read_ODCAPS_Subset_Binary( Filename, &
                                             ODCAPS%ODCAPS_Subset, &
                                             No_File_Close = SET, &
                                             Message_Log = Message_Log )

      IF ( Error_Status /= SUCCESS ) THEN
        WRITE( Message, '( "Error reading ODCAPS_Subset coefficients from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
        CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            Error_Status, &
                            Message_Log = Message_Log )
        CLOSE( FileID )
        RETURN

      END IF

    END IF

    !#--------------------------------------------------------------------------#
    !#                          -- CLOSE THE FILE --                            #
    !#--------------------------------------------------------------------------#

    CLOSE( FileID, STATUS = 'KEEP',   &
                   IOSTAT = IO_Status )

    IF ( IO_Status /= 0 ) THEN
      WRITE( Message, '( "Error closing ", a, ". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message )//TRIM( Process_ID_Tag ), &
                            WARNING, &
                            Message_Log = Message_Log )
    END IF


    !#--------------------------------------------------------------------------#
    !#                      -- OUTPUT AN INFO MESSAGE --                        #
    !#--------------------------------------------------------------------------#

    IF ( Noisy ) THEN
      CALL Info_ODCAPS( ODCAPS, Message )
      CALL Display_Message( ROUTINE_NAME, &
                            'FILE: '//TRIM( Filename )//'; '//TRIM( Message ), &
                            INFORMATION, &
                            Message_Log = Message_Log )
    END IF

  END FUNCTION Read_ODCAPS_Binary




!------------------------------------------------------------------------------
!S+
! NAME:
!       Write_ODCAPS_Binary
!
! PURPOSE:
!       Function to write Binary format ODCAPS files.
!
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       Error_Status = Write_ODCAPS_Binary( Filename,                 &   ! Input
!                                             ODCAPS,                 &   ! Input
!                                             Quiet       = Quiet,      &   ! Optional input
!                                             RCS_Id      = RCS_Id,     &   ! Revision control
!                                             Message_Log = Message_Log )   ! Error messaging
!
! INPUT ARGUMENTS:
!       Filename:     Character string specifying the name of an output
!                     ODCAPS format data file.
!                     UNITS:      N/A
!                     TYPE:       CHARACTER( * )
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( IN )
!
!       ODCAPS:     Structure containing the gas absorption coefficient data.
!                     UNITS:      N/A
!                     TYPE:       ODCAPS_type
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( IN )
!
! OPTIONAL INPUT ARGUMENTS:
!       Quiet:        Set this keyword to suppress information Messages being
!                     printed to standard output (or the Message log file if 
!                     the Message_Log optional argument is used.) By default,
!                     information Messages are printed.
!                     If QUIET = 0, information Messages are OUTPUT.
!                        QUIET = 1, information Messages are SUPPRESSED.
!                     UNITS:      N/A
!                     TYPE:       Integer
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( IN ), OPTIONAL
!
!       Message_Log:  Character string specifying a filename in which any
!                     Messages will be logged. If not specified, or if an
!                     error occurs opening the log file, the default action
!                     is to output Messages to standard output.
!                     UNITS:      N/A
!                     TYPE:       CHARACTER( * )
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( IN ), OPTIONAL
!
! OUTPUT ARGUMENTS:
!       None.
!
! OPTIONAL OUTPUT ARGUMENTS:
!       RCS_Id:       Character string containing the Revision Control
!                     System Id field for the module.
!                     UNITS:      N/A
!                     TYPE:       CHARACTER( * )
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: OPTIONAL, INTENT( OUT )
!
! FUNCTION RESULT:
!       Error_Status: The return value is an integer defining the error status.
!                     The error codes are defined in the Message_Handler module.
!                     If == SUCCESS the Binary file write was successful
!                        == FAILURE - the input ODCAPS structure contains
!                                     unassociated pointer members, or
!                                   - a unrecoverable write error occurred.
!                     UNITS:      N/A
!                     TYPE:       INTEGER
!                     DIMENSION:  Scalar
!
! CALLS:
!       Associated_ODCAPS:     Function to test the association status
!                                of the pointer members of a ODCAPS
!                                structure.
!                                SOURCE: ODCAPS_DEFINE module
!
!       Open_Binary_File:        Function to open Binary format
!                                data files.
!                                SOURCE: BINARY_FILE_UTILITY module
!
!       Info_ODCAPS:        Subroutine to return a string containing
!                                version and dimension information about
!                                a ODCAPS data structure.
!                                SOURCE: ODCAPS_DEFINE module
!
!       Display_Message:         Subroutine to output Messages
!                                SOURCE: Message_Handler module
!
! SIDE EFFECTS:
!       - If the output file already exists, it is overwritten.
!       - If an error occurs *during* the write phase, the output file is deleted
!         before returning to the calling routine.
!
! RESTRICTIONS:
!       None.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 05-May-2006
!                       Yong.Chen@noaa.gov
!S-
!------------------------------------------------------------------------------

  FUNCTION Write_ODCAPS_Binary( Filename,     &  ! Input
                                  ODCAPS,     &  ! Input
                                  Quiet,        &  ! Optional input
                                  RCS_Id,       &  ! Revision control
                                  Message_Log ) &  ! Error messaging
                                RESULT ( Error_Status )



    !#--------------------------------------------------------------------------#
    !#                          -- TYPE DECLARATIONS --                         #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Input
    CHARACTER( * ),           INTENT( IN )  :: Filename
    TYPE( ODCAPS_type ),    INTENT( IN )  :: ODCAPS

    ! -- Optional input
    INTEGER,        OPTIONAL, INTENT( IN )  :: Quiet

    ! -- Revision control
    CHARACTER( * ), OPTIONAL, INTENT( OUT ) :: RCS_Id

    ! -- Error Message log file
    CHARACTER( * ), OPTIONAL, INTENT( IN )  :: Message_Log


    ! ---------------
    ! Function result
    ! ---------------

    INTEGER :: Error_Status


    ! -------------------
    ! Function parameters
    ! -------------------

    CHARACTER( * ), PARAMETER :: ROUTINE_NAME = 'Write_ODCAPS_Binary'
    CHARACTER( * ), PARAMETER :: FILE_STATUS_ON_ERROR = 'DELETE'


    ! ------------------
    ! Function variables
    ! ------------------

    CHARACTER( 256 ) :: Message
    LOGICAL :: Noisy
    INTEGER :: IO_Status
    INTEGER :: FileID



    !#--------------------------------------------------------------------------#
    !#                     -- INITIALISE THE ERROR STATUS --                    #
    !#--------------------------------------------------------------------------#

    Error_Status = SUCCESS



    !#--------------------------------------------------------------------------#
    !#                -- CHECK/SET OPTIONAL KEYWORD ARGUMENTS --                #
    !#--------------------------------------------------------------------------#

    ! -------------------
    ! Info message output
    ! -------------------

    ! -- Output informational messages....
    Noisy = .TRUE.

    ! -- ....unless the QUIET keyword is set.
    IF ( PRESENT( Quiet ) ) THEN
      IF ( Quiet == SET ) Noisy = .FALSE.
    END IF


    ! -------------------
    ! Module version info
    ! -------------------

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF



    !#--------------------------------------------------------------------------#
    !#             -- CHECK STRUCTURE POINTER ASSOCIATION STATUS --             #
    !#                                                                          #
    !#                ALL structure pointers must be associated                 #
    !#--------------------------------------------------------------------------#

    IF ( .NOT. Associated_ODCAPS( ODCAPS ) ) THEN
      Error_Status = FAILURE
      CALL Display_Message( ROUTINE_NAME, &
                            'Some or all INPUT ODCAPS pointer '//&
                            'members are NOT associated.', &
                            Error_Status,    &
                            Message_Log = Message_Log )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#                          -- CHECK INPUT --                               #
    !#--------------------------------------------------------------------------#

    ! ------------------------------------
    ! Check the ODCAPS structure Release
    ! ------------------------------------

    Error_Status = CheckRelease_ODCAPS( ODCAPS, Message_Log = Message_Log )

    IF ( Error_Status /= SUCCESS ) THEN
      CALL Display_Message( ROUTINE_NAME, &
                            'ODCAPS Release check failed.', &
                            Error_Status, &
                            Message_Log = Message_Log )
      RETURN
    END IF


    ! ---------------------------------------
    ! Check the ODCAPS structure dimensions
    ! ---------------------------------------

    IF (ODCAPS% n_Layers	      < 1 .OR. &
        ODCAPS%n_Channels	      < 1 .OR. &
        ODCAPS%n_Tunings	      < 1 .OR. &
        ODCAPS%n_F_Predictors       < 1 .OR. &
        ODCAPS%n_RefProfile_Items   < 1 .OR. &
        ODCAPS%n_NONLTE_Predictors  < 1 .OR. &
	ODCAPS%n_Subsets            < 1 .OR. &
        ODCAPS%n_NONLTE_Channels    < 1      ) THEN
      Error_Status = FAILURE
      CALL Display_Message( ROUTINE_NAME, &
                            'One or more dimensions of ODCAPS structure are < or = 0.', &
                            Error_Status, &
                            Message_Log = Message_Log )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#            -- OPEN THE GAS ABSORPTION COEFFICIENT DATA FILE --           #
    !#--------------------------------------------------------------------------#

    Error_Status = Open_Binary_File( TRIM( Filename ), &
                                     FileID,   &
                                     For_Output  = SET,        &
                                     Message_Log = Message_Log )

    IF ( Error_Status /= SUCCESS ) THEN
      CALL Display_Message( ROUTINE_NAME, &
                            'Error opening '//TRIM( Filename ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#                     -- WRITE THE "FILE HEADER" --                        #
    !#--------------------------------------------------------------------------#

    ! -------------------------------------
    ! Write the Release/Version information
    ! -------------------------------------

    WRITE( FileID, IOSTAT = IO_Status ) ODCAPS%Release, &
                                        ODCAPS%Version 

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error writing ODCAPS file Release/Version values to ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID, STATUS = FILE_STATUS_ON_ERROR )
      RETURN
    END IF

    ! Write the Algorithm_ID
    WRITE( FileID, IOSTAT = IO_Status ) ODCAPS%Algorithm 

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error writing ODCAPS file  Algorithm_ID to ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID, STATUS = FILE_STATUS_ON_ERROR )
      RETURN
    END IF
    ! --------------------
    ! Write the dimensions
    ! --------------------

    WRITE( FileID, IOSTAT = IO_Status )  ODCAPS%n_Layers,	      &
                                         ODCAPS%n_Channels,	      &
                                         ODCAPS%n_Tunings,	      & 
                                         ODCAPS%n_F_Predictors,     & 
                                         ODCAPS%n_RefProfile_Items, & 
                                         ODCAPS%n_NONLTE_Predictors,& 
                                         ODCAPS%n_NONLTE_Channels,  & 
                                         ODCAPS%n_TraceGases,       &
                                         ODCAPS%n_Subsets 
    

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error writing data dimensions to ", a, ". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID, STATUS = FILE_STATUS_ON_ERROR )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                      -- WRITE THE SENSOR ID DATA --                      #
    !#--------------------------------------------------------------------------#

    WRITE( FileID, IOSTAT = IO_Status ) ODCAPS%Sensor_id, &
                                        ODCAPS%WMO_Satellite_ID, &
                                        ODCAPS%WMO_Sensor_ID, &
                                        ODCAPS%Sensor_Type 
 
    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error writing sensor ID data to ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#                     -- WRITE THE CHANNEL INDEX DATA --                     #
    !#--------------------------------------------------------------------------#

    WRITE( FileID, IOSTAT = IO_Status ) ODCAPS%Sensor_Channel, 	    &
                                        ODCAPS%Channel_Subset_Index,      &
                                        ODCAPS%Channel_Subset_Position,   &
                                        ODCAPS%Channel_H2O_OPTRAN,	    &
                                        ODCAPS%Channel_CO2_Perturbation , &
                                        ODCAPS%Channel_SO2_Perturbation , &
                                        ODCAPS%Channel_HNO3_Perturbation, &
                                        ODCAPS%Channel_N2O_Perturbation,  &
                                        ODCAPS%Channel_NON_LTE  

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error writing Index data data to ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#           -- WRITE THE STANDARD LEVEL PRESSURE  DATA --                  #
    !#--------------------------------------------------------------------------#

    WRITE( FileID, IOSTAT = IO_Status ) ODCAPS%Standard_Level_Pressure  
    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error writing Standard level pressure data to ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#      -- WRITE THE Fix_Gases,Down_F_Factor,Tuning_Multiple DATA --        #
    !#--------------------------------------------------------------------------#

    WRITE( FileID, IOSTAT = IO_Status ) ODCAPS%Fix_Gases_Adjustment, &
                                        ODCAPS%Down_F_Factor, &
                                        ODCAPS%Tuning_Multiple 

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error writing Fix_Gases_Adjustment data to ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                    -- WRITE THE REFERENCE PROFIEL DATA --                #
    !#--------------------------------------------------------------------------#

    WRITE( FileID, IOSTAT = IO_Status ) ODCAPS%Ref_Profile_Data 

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error writing reference profile data to ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                -- WRITE THE NON-LTE COEFFICIENTS  --               #
    !#--------------------------------------------------------------------------#

    WRITE( FileID, IOSTAT = IO_Status ) ODCAPS%Non_LTE_Coeff 

    IF ( IO_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error writing non-LTE coefficients to ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    !#--------------------------------------------------------------------------#
    !#                -- WRITE THE WATER VAPOR OPTRAN COEFFICIENTS DATA--        #
    !#--------------------------------------------------------------------------#

    ! ---------------------
    ! Get the data filename
    ! ---------------------
 
    !INQUIRE( UNIT = FileID, NAME = Filename )

    ! ---------------------------------------------
    ! Read the water vapor optran coefficients data 
    ! ---------------------------------------------

    Error_Status = Write_ODCAPS_ODAS_Binary(Filename, &
                                                ODCAPS%ODCAPS_ODAS, &
                                                No_File_Close = SET, &
                                                Message_Log = Message_Log )

    IF ( Error_Status /= SUCCESS ) THEN
      WRITE( Message, '( "Error writing water OPTRAN absorption coefficients from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
      CLOSE( FileID )
      RETURN
    END IF

    !#--------------------------------------------------------------------------#
    !#              - WRITE THE ODCAPS_TraceGas DATA --                       #
    !#--------------------------------------------------------------------------#

    IF ( ODCAPS%n_TraceGases > 0 ) THEN


      ! ---------------------
      ! Get the data filename
      ! ---------------------

      !INQUIRE( UNIT = FileID, NAME = Filename )


      ! -------------------
      ! Write the ODCAPS_TraceGas data
      ! -------------------

      Error_Status = Write_ODCAPS_TraceGas_Binary( Filename, &
                                             ODCAPS%ODCAPS_TraceGas, &
                                             No_File_Close = SET, &
                                             Message_Log = Message_Log )

      IF ( Error_Status /= SUCCESS ) THEN
        WRITE( Message, '( "Error writing ODCAPS_TraceGas coefficients from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
        CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
        CLOSE( FileID )
        RETURN

      END IF

    END IF


    !#--------------------------------------------------------------------------#
    !#                -- WRITE THE ODCAPS_Subset DATA --                      #
    !#--------------------------------------------------------------------------#

    IF (ODCAPS%n_Subsets > 0 ) THEN


      ! ---------------------
      ! Get the data filename
      ! ---------------------

      !INQUIRE( UNIT = FileID, NAME = Filename )


      ! -------------------
      ! Write the ODCAPS_Subset data
      ! -------------------

      Error_Status = Write_ODCAPS_Subset_Binary( Filename, &
                                             ODCAPS%ODCAPS_Subset, &
                                             No_File_Close = SET, &
                                             Message_Log = Message_Log )

      IF ( Error_Status /= SUCCESS ) THEN
        WRITE( Message, '( "Error writing ODCAPS_Subset coefficients from ", a, &
                        &". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
        CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            Error_Status, &
                            Message_Log = Message_Log )
        CLOSE( FileID )
        RETURN

      END IF

    END IF


    !#--------------------------------------------------------------------------#
    !#                          -- CLOSE THE FILE --                            #
    !#--------------------------------------------------------------------------#

    CLOSE( FileID, STATUS = 'KEEP',   &
                   IOSTAT = IO_Status )

    IF ( IO_Status /= 0 ) THEN
      WRITE( Message, '( "Error closing ", a, ". IOSTAT = ", i5 )' ) &
                      TRIM( Filename ), IO_Status
      CALL Display_Message( ROUTINE_NAME, &
                            TRIM( Message ), &
                            WARNING, &
                            Message_Log = Message_Log )
    END IF



    !#--------------------------------------------------------------------------#
    !#                      -- OUTPUT AN INFO MESSAGE --                        #
    !#--------------------------------------------------------------------------#

    IF ( Noisy ) THEN
      CALL Info_ODCAPS( ODCAPS, Message )
      CALL Display_Message( ROUTINE_NAME, &
                            'FILE: '//TRIM( Filename )//'; '//TRIM( Message ), &
                            INFORMATION, &
                            Message_Log = Message_Log )
    END IF

  END FUNCTION Write_ODCAPS_Binary

END MODULE ODCAPS_Binary_IO
