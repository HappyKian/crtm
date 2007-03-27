!
!-------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       CRTM_OCEANEM_AMSRE
!
! PURPOSE:
!       This module computes ocean emissivity and its jacobian over water. 
!                                                                               
! Method:                                                                       
!                                                                               
! History:   
!                                                                   
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CREATION HISTORY:
!
!   2006-07-31  Created for CRTM
!               by:     Masahiro Kazumori, JCSDA,     Masahiro.Kazumori@noaa.gov 
!                       Quanhua Liu, QSS Group Inc.,     Quanhua.Liu@noaa.gov 
!
!  This program is free software; you can redistribute it and/or modify it under the terms of the GNU
!  General Public License as published by the Free Software Foundation; either version 2 of the License,
!  or (at your option) any later version.
!
!  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
!  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
!  License for more details.
!
!  You should have received a copy of the GNU General Public License along with this program; if not, write
!  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
!
!M-
!------------------------------------------------------------------------------------------------------------

MODULE CRTM_OCEANEM_AMSRE

  ! ----------
  ! Module use
  ! ----------

  USE Type_Kinds

  ! -- CRTM modules
  USE CRTM_Parameters

  ! -----------------------
  ! Disable implicit typing
  ! -----------------------

  IMPLICIT NONE

  PRIVATE

  PUBLIC :: OCEANEM_AMSRE
  PUBLIC :: OCEANEM_AMSRE_TL
  PUBLIC :: OCEANEM_AMSRE_AD
  PUBLIC :: Compute_Ellison_eps_ocean
  PUBLIC :: Compute_Ellison_eps_ocean_TL
  PUBLIC :: Compute_Ellison_eps_ocean_AD
  PUBLIC :: Compute_Guillou_eps_ocean
  PUBLIC :: Compute_Guillou_eps_ocean_TL
  PUBLIC :: Compute_Guillou_eps_ocean_AD
  PUBLIC :: FRESNEL
  PUBLIC :: FRESNEL_TL
  PUBLIC :: FRESNEL_AD

  INTEGER :: j

  REAL( fp_kind ), SAVE :: sdd(40,100)
  REAL( fp_kind ), SAVE :: Coeff(8)

  DATA (Coeff(j),j=1,8) / &
  -2.616e-05_fp_kind, 1.407e-05_fp_kind,-1.738e-07_fp_kind, &
  -2.616e-05_fp_kind,-1.389e-05_fp_kind,-6.106e-08_fp_kind, &
   1.90896_fp_kind, 0.120448_fp_kind/

DATA (sdd(1,j),j=1,100) / &
 0.34570E-02_fp_kind, 0.96028E-02_fp_kind, 0.18661E-01_fp_kind, 0.26397E-01_fp_kind, 0.29960E-01_fp_kind,&
 0.31163E-01_fp_kind, 0.31130E-01_fp_kind, 0.30225E-01_fp_kind, 0.28781E-01_fp_kind, 0.27321E-01_fp_kind,&
 0.25720E-01_fp_kind, 0.24130E-01_fp_kind, 0.22348E-01_fp_kind, 0.20483E-01_fp_kind, 0.20208E-01_fp_kind,&
 0.20297E-01_fp_kind, 0.20351E-01_fp_kind, 0.20571E-01_fp_kind, 0.20546E-01_fp_kind, 0.20678E-01_fp_kind,&
 0.20580E-01_fp_kind, 0.20630E-01_fp_kind, 0.20640E-01_fp_kind, 0.20611E-01_fp_kind, 0.20546E-01_fp_kind,&
 0.20446E-01_fp_kind, 0.20477E-01_fp_kind, 0.20308E-01_fp_kind, 0.20269E-01_fp_kind, 0.20195E-01_fp_kind,&
 0.19935E-01_fp_kind, 0.19801E-01_fp_kind, 0.19788E-01_fp_kind, 0.19595E-01_fp_kind, 0.19375E-01_fp_kind,&
 0.19275E-01_fp_kind, 0.19148E-01_fp_kind, 0.18994E-01_fp_kind, 0.18816E-01_fp_kind, 0.18613E-01_fp_kind,&
 0.18387E-01_fp_kind, 0.18278E-01_fp_kind, 0.18006E-01_fp_kind, 0.17852E-01_fp_kind, 0.17676E-01_fp_kind,&
 0.17478E-01_fp_kind, 0.17260E-01_fp_kind, 0.17022E-01_fp_kind, 0.16799E-01_fp_kind, 0.16715E-01_fp_kind,&
 0.16469E-01_fp_kind, 0.16214E-01_fp_kind, 0.16094E-01_fp_kind, 0.15963E-01_fp_kind, 0.15679E-01_fp_kind,&
 0.15527E-01_fp_kind, 0.15366E-01_fp_kind, 0.15195E-01_fp_kind, 0.15015E-01_fp_kind, 0.14826E-01_fp_kind,&
 0.14628E-01_fp_kind, 0.14423E-01_fp_kind, 0.14343E-01_fp_kind, 0.14121E-01_fp_kind, 0.13891E-01_fp_kind,&
 0.13786E-01_fp_kind, 0.13672E-01_fp_kind, 0.13420E-01_fp_kind, 0.13291E-01_fp_kind, 0.13154E-01_fp_kind,&
 0.13010E-01_fp_kind, 0.12858E-01_fp_kind, 0.12699E-01_fp_kind, 0.12533E-01_fp_kind, 0.12361E-01_fp_kind,&
 0.12182E-01_fp_kind, 0.12122E-01_fp_kind, 0.11930E-01_fp_kind, 0.11731E-01_fp_kind, 0.11651E-01_fp_kind,&
 0.11440E-01_fp_kind, 0.11347E-01_fp_kind, 0.11248E-01_fp_kind, 0.11143E-01_fp_kind, 0.10908E-01_fp_kind,&
 0.10791E-01_fp_kind, 0.10667E-01_fp_kind, 0.10539E-01_fp_kind, 0.10404E-01_fp_kind, 0.10264E-01_fp_kind,&
 0.10242E-01_fp_kind, 0.10091E-01_fp_kind, 0.99343E-02_fp_kind, 0.97724E-02_fp_kind, 0.97294E-02_fp_kind,&
 0.95568E-02_fp_kind, 0.95038E-02_fp_kind, 0.94462E-02_fp_kind, 0.96390E-02_fp_kind, 0.97032E-02_fp_kind/

DATA (sdd(2,j),j=1,100) / &
 0.40478E-01_fp_kind, 0.42657E-01_fp_kind, 0.43063E-01_fp_kind, 0.42265E-01_fp_kind, 0.40754E-01_fp_kind,&
 0.39474E-01_fp_kind, 0.37890E-01_fp_kind, 0.36005E-01_fp_kind, 0.34181E-01_fp_kind, 0.32422E-01_fp_kind,&
 0.30415E-01_fp_kind, 0.28573E-01_fp_kind, 0.28867E-01_fp_kind, 0.29091E-01_fp_kind, 0.29244E-01_fp_kind,&
 0.29601E-01_fp_kind, 0.29609E-01_fp_kind, 0.29555E-01_fp_kind, 0.29686E-01_fp_kind, 0.29744E-01_fp_kind,&
 0.29735E-01_fp_kind, 0.29663E-01_fp_kind, 0.29531E-01_fp_kind, 0.29343E-01_fp_kind, 0.29316E-01_fp_kind,&
 0.29232E-01_fp_kind, 0.28888E-01_fp_kind, 0.28704E-01_fp_kind, 0.28671E-01_fp_kind, 0.28391E-01_fp_kind,&
 0.28070E-01_fp_kind, 0.27901E-01_fp_kind, 0.27689E-01_fp_kind, 0.27438E-01_fp_kind, 0.27150E-01_fp_kind,&
 0.26827E-01_fp_kind, 0.26650E-01_fp_kind, 0.26437E-01_fp_kind, 0.26336E-01_fp_kind, 0.26108E-01_fp_kind,&
 0.25860E-01_fp_kind, 0.25593E-01_fp_kind, 0.25308E-01_fp_kind, 0.25007E-01_fp_kind, 0.24691E-01_fp_kind,&
 0.24361E-01_fp_kind, 0.24018E-01_fp_kind, 0.24001E-01_fp_kind, 0.23631E-01_fp_kind, 0.23251E-01_fp_kind,&
 0.23186E-01_fp_kind, 0.22784E-01_fp_kind, 0.22690E-01_fp_kind, 0.22270E-01_fp_kind, 0.22151E-01_fp_kind,&
 0.22019E-01_fp_kind, 0.21573E-01_fp_kind, 0.21419E-01_fp_kind, 0.21254E-01_fp_kind, 0.21078E-01_fp_kind,&
 0.20605E-01_fp_kind, 0.20412E-01_fp_kind, 0.20210E-01_fp_kind, 0.20000E-01_fp_kind, 0.19781E-01_fp_kind,&
 0.19554E-01_fp_kind, 0.19320E-01_fp_kind, 0.19348E-01_fp_kind, 0.19097E-01_fp_kind, 0.18839E-01_fp_kind,&
 0.18575E-01_fp_kind, 0.18305E-01_fp_kind, 0.18288E-01_fp_kind, 0.18004E-01_fp_kind, 0.17970E-01_fp_kind,&
 0.17674E-01_fp_kind, 0.17373E-01_fp_kind, 0.17316E-01_fp_kind, 0.17004E-01_fp_kind, 0.16933E-01_fp_kind,&
 0.16856E-01_fp_kind, 0.16526E-01_fp_kind, 0.16435E-01_fp_kind, 0.16338E-01_fp_kind, 0.15993E-01_fp_kind,&
 0.15883E-01_fp_kind, 0.15768E-01_fp_kind, 0.15646E-01_fp_kind, 0.15518E-01_fp_kind, 0.15149E-01_fp_kind,&
 0.15010E-01_fp_kind, 0.14866E-01_fp_kind, 0.14717E-01_fp_kind, 0.14562E-01_fp_kind, 0.14402E-01_fp_kind,&
 0.14237E-01_fp_kind, 0.14066E-01_fp_kind, 0.14122E-01_fp_kind, 0.13941E-01_fp_kind, 0.13756E-01_fp_kind/

DATA (sdd(3,j),j=1,100) / &
 0.45959E-01_fp_kind, 0.44809E-01_fp_kind, 0.44642E-01_fp_kind, 0.43633E-01_fp_kind, 0.42489E-01_fp_kind,&
 0.41514E-01_fp_kind, 0.40195E-01_fp_kind, 0.38867E-01_fp_kind, 0.37478E-01_fp_kind, 0.36003E-01_fp_kind,&
 0.35326E-01_fp_kind, 0.35519E-01_fp_kind, 0.35983E-01_fp_kind, 0.36334E-01_fp_kind, 0.36577E-01_fp_kind,&
 0.36717E-01_fp_kind, 0.36760E-01_fp_kind, 0.36712E-01_fp_kind, 0.36579E-01_fp_kind, 0.36639E-01_fp_kind,&
 0.36610E-01_fp_kind, 0.36498E-01_fp_kind, 0.36311E-01_fp_kind, 0.36053E-01_fp_kind, 0.35974E-01_fp_kind,&
 0.35586E-01_fp_kind, 0.35377E-01_fp_kind, 0.35108E-01_fp_kind, 0.34784E-01_fp_kind, 0.34631E-01_fp_kind,&
 0.34204E-01_fp_kind, 0.33949E-01_fp_kind, 0.33647E-01_fp_kind, 0.33301E-01_fp_kind, 0.33569E-01_fp_kind,&
 0.32999E-01_fp_kind, 0.32998E-01_fp_kind, 0.32381E-01_fp_kind, 0.32317E-01_fp_kind, 0.31662E-01_fp_kind,&
 0.31544E-01_fp_kind, 0.30859E-01_fp_kind, 0.30696E-01_fp_kind, 0.30509E-01_fp_kind, 0.30300E-01_fp_kind,&
 0.29564E-01_fp_kind, 0.29323E-01_fp_kind, 0.29063E-01_fp_kind, 0.28788E-01_fp_kind, 0.28497E-01_fp_kind,&
 0.28193E-01_fp_kind, 0.27875E-01_fp_kind, 0.27546E-01_fp_kind, 0.27205E-01_fp_kind, 0.27299E-01_fp_kind,&
 0.26932E-01_fp_kind, 0.26556E-01_fp_kind, 0.26173E-01_fp_kind, 0.25783E-01_fp_kind, 0.25802E-01_fp_kind,&
 0.25392E-01_fp_kind, 0.25386E-01_fp_kind, 0.24959E-01_fp_kind, 0.24528E-01_fp_kind, 0.24488E-01_fp_kind,&
 0.24043E-01_fp_kind, 0.23982E-01_fp_kind, 0.23525E-01_fp_kind, 0.23444E-01_fp_kind, 0.23353E-01_fp_kind,&
 0.22878E-01_fp_kind, 0.22770E-01_fp_kind, 0.22654E-01_fp_kind, 0.22164E-01_fp_kind, 0.22031E-01_fp_kind,&
 0.21891E-01_fp_kind, 0.21743E-01_fp_kind, 0.21588E-01_fp_kind, 0.21074E-01_fp_kind, 0.20906E-01_fp_kind,&
 0.20731E-01_fp_kind, 0.20549E-01_fp_kind, 0.20361E-01_fp_kind, 0.20166E-01_fp_kind, 0.19966E-01_fp_kind,&
 0.19759E-01_fp_kind, 0.19546E-01_fp_kind, 0.19328E-01_fp_kind, 0.19105E-01_fp_kind, 0.18876E-01_fp_kind,&
 0.18967E-01_fp_kind, 0.18726E-01_fp_kind, 0.18480E-01_fp_kind, 0.18229E-01_fp_kind, 0.17974E-01_fp_kind,&
 0.18031E-01_fp_kind, 0.17764E-01_fp_kind, 0.17494E-01_fp_kind, 0.17533E-01_fp_kind, 0.17252E-01_fp_kind/

DATA (sdd(4,j),j=1,100) / &
 0.45945E-01_fp_kind, 0.45855E-01_fp_kind, 0.44704E-01_fp_kind, 0.44627E-01_fp_kind, 0.44112E-01_fp_kind,&
 0.43270E-01_fp_kind, 0.42801E-01_fp_kind, 0.41951E-01_fp_kind, 0.41044E-01_fp_kind, 0.40817E-01_fp_kind,&
 0.41171E-01_fp_kind, 0.41824E-01_fp_kind, 0.41939E-01_fp_kind, 0.42316E-01_fp_kind, 0.42557E-01_fp_kind,&
 0.42671E-01_fp_kind, 0.42667E-01_fp_kind, 0.42554E-01_fp_kind, 0.42649E-01_fp_kind, 0.42633E-01_fp_kind,&
 0.42222E-01_fp_kind, 0.42304E-01_fp_kind, 0.42009E-01_fp_kind, 0.41636E-01_fp_kind, 0.41459E-01_fp_kind,&
 0.41207E-01_fp_kind, 0.40885E-01_fp_kind, 0.40501E-01_fp_kind, 0.40306E-01_fp_kind, 0.39808E-01_fp_kind,&
 0.39499E-01_fp_kind, 0.39962E-01_fp_kind, 0.39076E-01_fp_kind, 0.38967E-01_fp_kind, 0.38814E-01_fp_kind,&
 0.37852E-01_fp_kind, 0.37630E-01_fp_kind, 0.37373E-01_fp_kind, 0.37085E-01_fp_kind, 0.36767E-01_fp_kind,&
 0.36422E-01_fp_kind, 0.36053E-01_fp_kind, 0.35661E-01_fp_kind, 0.35250E-01_fp_kind, 0.34819E-01_fp_kind,&
 0.34373E-01_fp_kind, 0.33911E-01_fp_kind, 0.33436E-01_fp_kind, 0.33563E-01_fp_kind, 0.33054E-01_fp_kind,&
 0.32535E-01_fp_kind, 0.32598E-01_fp_kind, 0.32052E-01_fp_kind, 0.31501E-01_fp_kind, 0.31508E-01_fp_kind,&
 0.30936E-01_fp_kind, 0.30910E-01_fp_kind, 0.30322E-01_fp_kind, 0.30266E-01_fp_kind, 0.29664E-01_fp_kind,&
 0.29582E-01_fp_kind, 0.28968E-01_fp_kind, 0.28862E-01_fp_kind, 0.28744E-01_fp_kind, 0.28113E-01_fp_kind,&
 0.27973E-01_fp_kind, 0.27823E-01_fp_kind, 0.27662E-01_fp_kind, 0.27491E-01_fp_kind, 0.26834E-01_fp_kind,&
 0.26647E-01_fp_kind, 0.26450E-01_fp_kind, 0.26245E-01_fp_kind, 0.26032E-01_fp_kind, 0.25811E-01_fp_kind,&
 0.25582E-01_fp_kind, 0.25345E-01_fp_kind, 0.25101E-01_fp_kind, 0.24851E-01_fp_kind, 0.24593E-01_fp_kind,&
 0.24330E-01_fp_kind, 0.24060E-01_fp_kind, 0.23785E-01_fp_kind, 0.23504E-01_fp_kind, 0.23217E-01_fp_kind,&
 0.23341E-01_fp_kind, 0.23040E-01_fp_kind, 0.22735E-01_fp_kind, 0.22425E-01_fp_kind, 0.22110E-01_fp_kind,&
 0.22193E-01_fp_kind, 0.21867E-01_fp_kind, 0.21536E-01_fp_kind, 0.21597E-01_fp_kind, 0.21255E-01_fp_kind,&
 0.20910E-01_fp_kind, 0.20950E-01_fp_kind, 0.20594E-01_fp_kind, 0.20622E-01_fp_kind, 0.20255E-01_fp_kind/

DATA (sdd(5,j),j=1,100) / &
 0.46455E-01_fp_kind, 0.45636E-01_fp_kind, 0.45913E-01_fp_kind, 0.45552E-01_fp_kind, 0.45316E-01_fp_kind,&
 0.45144E-01_fp_kind, 0.45307E-01_fp_kind, 0.45161E-01_fp_kind, 0.45272E-01_fp_kind, 0.45909E-01_fp_kind,&
 0.46722E-01_fp_kind, 0.46917E-01_fp_kind, 0.47397E-01_fp_kind, 0.47714E-01_fp_kind, 0.47877E-01_fp_kind,&
 0.47899E-01_fp_kind, 0.48144E-01_fp_kind, 0.47902E-01_fp_kind, 0.47884E-01_fp_kind, 0.47747E-01_fp_kind,&
 0.47502E-01_fp_kind, 0.47160E-01_fp_kind, 0.47029E-01_fp_kind, 0.46805E-01_fp_kind, 0.46497E-01_fp_kind,&
 0.46113E-01_fp_kind, 0.45662E-01_fp_kind, 0.45416E-01_fp_kind, 0.44844E-01_fp_kind, 0.45516E-01_fp_kind,&
 0.45348E-01_fp_kind, 0.44124E-01_fp_kind, 0.43860E-01_fp_kind, 0.43549E-01_fp_kind, 0.43193E-01_fp_kind,&
 0.42798E-01_fp_kind, 0.42367E-01_fp_kind, 0.41904E-01_fp_kind, 0.41412E-01_fp_kind, 0.40894E-01_fp_kind,&
 0.40353E-01_fp_kind, 0.40615E-01_fp_kind, 0.40017E-01_fp_kind, 0.39404E-01_fp_kind, 0.38777E-01_fp_kind,&
 0.38909E-01_fp_kind, 0.38243E-01_fp_kind, 0.37569E-01_fp_kind, 0.37622E-01_fp_kind, 0.36920E-01_fp_kind,&
 0.36926E-01_fp_kind, 0.36201E-01_fp_kind, 0.36167E-01_fp_kind, 0.35424E-01_fp_kind, 0.35353E-01_fp_kind,&
 0.34597E-01_fp_kind, 0.34493E-01_fp_kind, 0.34373E-01_fp_kind, 0.33596E-01_fp_kind, 0.33449E-01_fp_kind,&
 0.33287E-01_fp_kind, 0.33112E-01_fp_kind, 0.32313E-01_fp_kind, 0.32116E-01_fp_kind, 0.31907E-01_fp_kind,&
 0.31686E-01_fp_kind, 0.31455E-01_fp_kind, 0.31213E-01_fp_kind, 0.30961E-01_fp_kind, 0.30137E-01_fp_kind,&
 0.29871E-01_fp_kind, 0.29598E-01_fp_kind, 0.29315E-01_fp_kind, 0.29025E-01_fp_kind, 0.28728E-01_fp_kind,&
 0.28954E-01_fp_kind, 0.28637E-01_fp_kind, 0.28313E-01_fp_kind, 0.27984E-01_fp_kind, 0.27648E-01_fp_kind,&
 0.27307E-01_fp_kind, 0.26961E-01_fp_kind, 0.27109E-01_fp_kind, 0.26747E-01_fp_kind, 0.26381E-01_fp_kind,&
 0.26010E-01_fp_kind, 0.26121E-01_fp_kind, 0.25736E-01_fp_kind, 0.25348E-01_fp_kind, 0.25433E-01_fp_kind,&
 0.25032E-01_fp_kind, 0.24629E-01_fp_kind, 0.24689E-01_fp_kind, 0.24274E-01_fp_kind, 0.23856E-01_fp_kind,&
 0.23894E-01_fp_kind, 0.23466E-01_fp_kind, 0.23489E-01_fp_kind, 0.23051E-01_fp_kind, 0.23061E-01_fp_kind/

DATA (sdd(6,j),j=1,100) / &
 0.46620E-01_fp_kind, 0.45952E-01_fp_kind, 0.45859E-01_fp_kind, 0.46020E-01_fp_kind, 0.45948E-01_fp_kind,&
 0.46469E-01_fp_kind, 0.46514E-01_fp_kind, 0.47047E-01_fp_kind, 0.47274E-01_fp_kind, 0.48506E-01_fp_kind,&
 0.49051E-01_fp_kind, 0.49433E-01_fp_kind, 0.50083E-01_fp_kind, 0.50135E-01_fp_kind, 0.50437E-01_fp_kind,&
 0.50579E-01_fp_kind, 0.50572E-01_fp_kind, 0.50431E-01_fp_kind, 0.50168E-01_fp_kind, 0.50127E-01_fp_kind,&
 0.49968E-01_fp_kind, 0.49704E-01_fp_kind, 0.49344E-01_fp_kind, 0.48900E-01_fp_kind, 0.48673E-01_fp_kind,&
 0.48365E-01_fp_kind, 0.47984E-01_fp_kind, 0.47540E-01_fp_kind, 0.47521E-01_fp_kind, 0.47331E-01_fp_kind,&
 0.47077E-01_fp_kind, 0.46765E-01_fp_kind, 0.46401E-01_fp_kind, 0.45989E-01_fp_kind, 0.45534E-01_fp_kind,&
 0.45041E-01_fp_kind, 0.44514E-01_fp_kind, 0.43956E-01_fp_kind, 0.43370E-01_fp_kind, 0.42761E-01_fp_kind,&
 0.43032E-01_fp_kind, 0.42362E-01_fp_kind, 0.41678E-01_fp_kind, 0.41838E-01_fp_kind, 0.41109E-01_fp_kind,&
 0.40371E-01_fp_kind, 0.40441E-01_fp_kind, 0.39671E-01_fp_kind, 0.39688E-01_fp_kind, 0.38893E-01_fp_kind,&
 0.38864E-01_fp_kind, 0.38049E-01_fp_kind, 0.37979E-01_fp_kind, 0.37150E-01_fp_kind, 0.37043E-01_fp_kind,&
 0.36918E-01_fp_kind, 0.36067E-01_fp_kind, 0.35912E-01_fp_kind, 0.35741E-01_fp_kind, 0.35554E-01_fp_kind,&
 0.34681E-01_fp_kind, 0.34471E-01_fp_kind, 0.34248E-01_fp_kind, 0.34013E-01_fp_kind, 0.33765E-01_fp_kind,&
 0.33506E-01_fp_kind, 0.32612E-01_fp_kind, 0.32338E-01_fp_kind, 0.32055E-01_fp_kind, 0.31761E-01_fp_kind,&
 0.31459E-01_fp_kind, 0.31149E-01_fp_kind, 0.30831E-01_fp_kind, 0.31084E-01_fp_kind, 0.30745E-01_fp_kind,&
 0.30398E-01_fp_kind, 0.30045E-01_fp_kind, 0.29686E-01_fp_kind, 0.29322E-01_fp_kind, 0.28951E-01_fp_kind,&
 0.29120E-01_fp_kind, 0.28733E-01_fp_kind, 0.28342E-01_fp_kind, 0.27946E-01_fp_kind, 0.28074E-01_fp_kind,&
 0.27663E-01_fp_kind, 0.27249E-01_fp_kind, 0.26832E-01_fp_kind, 0.26922E-01_fp_kind, 0.26491E-01_fp_kind,&
 0.26565E-01_fp_kind, 0.26122E-01_fp_kind, 0.25678E-01_fp_kind, 0.25726E-01_fp_kind, 0.25271E-01_fp_kind,&
 0.25304E-01_fp_kind, 0.24839E-01_fp_kind, 0.24857E-01_fp_kind, 0.24382E-01_fp_kind, 0.24386E-01_fp_kind/

DATA (sdd(7,j),j=1,100) / &
 0.46143E-01_fp_kind, 0.46246E-01_fp_kind, 0.46381E-01_fp_kind, 0.46743E-01_fp_kind, 0.47704E-01_fp_kind,&
 0.48584E-01_fp_kind, 0.49564E-01_fp_kind, 0.51213E-01_fp_kind, 0.52502E-01_fp_kind, 0.52983E-01_fp_kind,&
 0.53846E-01_fp_kind, 0.54489E-01_fp_kind, 0.54444E-01_fp_kind, 0.54713E-01_fp_kind, 0.55248E-01_fp_kind,&
 0.55160E-01_fp_kind, 0.54926E-01_fp_kind, 0.54958E-01_fp_kind, 0.54846E-01_fp_kind, 0.54607E-01_fp_kind,&
 0.54253E-01_fp_kind, 0.54152E-01_fp_kind, 0.53599E-01_fp_kind, 0.53304E-01_fp_kind, 0.52924E-01_fp_kind,&
 0.52789E-01_fp_kind, 0.52262E-01_fp_kind, 0.52437E-01_fp_kind, 0.52143E-01_fp_kind, 0.51778E-01_fp_kind,&
 0.51349E-01_fp_kind, 0.50863E-01_fp_kind, 0.50326E-01_fp_kind, 0.49744E-01_fp_kind, 0.49121E-01_fp_kind,&
 0.48463E-01_fp_kind, 0.48872E-01_fp_kind, 0.48129E-01_fp_kind, 0.47364E-01_fp_kind, 0.46579E-01_fp_kind,&
 0.46795E-01_fp_kind, 0.45954E-01_fp_kind, 0.46092E-01_fp_kind, 0.45206E-01_fp_kind, 0.44316E-01_fp_kind,&
 0.44354E-01_fp_kind, 0.43434E-01_fp_kind, 0.43415E-01_fp_kind, 0.43368E-01_fp_kind, 0.42404E-01_fp_kind,&
 0.42311E-01_fp_kind, 0.41335E-01_fp_kind, 0.41201E-01_fp_kind, 0.41045E-01_fp_kind, 0.40870E-01_fp_kind,&
 0.39861E-01_fp_kind, 0.39655E-01_fp_kind, 0.39431E-01_fp_kind, 0.39191E-01_fp_kind, 0.38168E-01_fp_kind,&
 0.37905E-01_fp_kind, 0.37628E-01_fp_kind, 0.37338E-01_fp_kind, 0.37036E-01_fp_kind, 0.36722E-01_fp_kind,&
 0.36396E-01_fp_kind, 0.36060E-01_fp_kind, 0.35715E-01_fp_kind, 0.35360E-01_fp_kind, 0.34995E-01_fp_kind,&
 0.34623E-01_fp_kind, 0.34243E-01_fp_kind, 0.33855E-01_fp_kind, 0.33460E-01_fp_kind, 0.33706E-01_fp_kind,&
 0.33290E-01_fp_kind, 0.32869E-01_fp_kind, 0.32442E-01_fp_kind, 0.32010E-01_fp_kind, 0.32191E-01_fp_kind,&
 0.31741E-01_fp_kind, 0.31288E-01_fp_kind, 0.30831E-01_fp_kind, 0.30966E-01_fp_kind, 0.30494E-01_fp_kind,&
 0.30018E-01_fp_kind, 0.30123E-01_fp_kind, 0.29634E-01_fp_kind, 0.29720E-01_fp_kind, 0.29219E-01_fp_kind,&
 0.28715E-01_fp_kind, 0.28773E-01_fp_kind, 0.28259E-01_fp_kind, 0.28300E-01_fp_kind, 0.27775E-01_fp_kind,&
 0.27800E-01_fp_kind, 0.27265E-01_fp_kind, 0.27274E-01_fp_kind, 0.26731E-01_fp_kind, 0.26724E-01_fp_kind/

DATA (sdd(8,j),j=1,100) / &
 0.46692E-01_fp_kind, 0.46031E-01_fp_kind, 0.46687E-01_fp_kind, 0.47713E-01_fp_kind, 0.48612E-01_fp_kind,&
 0.49918E-01_fp_kind, 0.51796E-01_fp_kind, 0.53723E-01_fp_kind, 0.54680E-01_fp_kind, 0.55440E-01_fp_kind,&
 0.56001E-01_fp_kind, 0.56366E-01_fp_kind, 0.57066E-01_fp_kind, 0.57042E-01_fp_kind, 0.57336E-01_fp_kind,&
 0.57445E-01_fp_kind, 0.57387E-01_fp_kind, 0.57179E-01_fp_kind, 0.56839E-01_fp_kind, 0.56785E-01_fp_kind,&
 0.56603E-01_fp_kind, 0.56309E-01_fp_kind, 0.55916E-01_fp_kind, 0.55437E-01_fp_kind, 0.55234E-01_fp_kind,&
 0.54607E-01_fp_kind, 0.55954E-01_fp_kind, 0.54239E-01_fp_kind, 0.53872E-01_fp_kind, 0.53434E-01_fp_kind,&
 0.52933E-01_fp_kind, 0.52376E-01_fp_kind, 0.53026E-01_fp_kind, 0.52345E-01_fp_kind, 0.51625E-01_fp_kind,&
 0.50872E-01_fp_kind, 0.50089E-01_fp_kind, 0.50423E-01_fp_kind, 0.49565E-01_fp_kind, 0.48690E-01_fp_kind,&
 0.48881E-01_fp_kind, 0.47953E-01_fp_kind, 0.47017E-01_fp_kind, 0.47093E-01_fp_kind, 0.46120E-01_fp_kind,&
 0.46130E-01_fp_kind, 0.46108E-01_fp_kind, 0.45084E-01_fp_kind, 0.45008E-01_fp_kind, 0.43969E-01_fp_kind,&
 0.43847E-01_fp_kind, 0.43700E-01_fp_kind, 0.42637E-01_fp_kind, 0.42453E-01_fp_kind, 0.42248E-01_fp_kind,&
 0.42024E-01_fp_kind, 0.40939E-01_fp_kind, 0.40687E-01_fp_kind, 0.40419E-01_fp_kind, 0.40135E-01_fp_kind,&
 0.39837E-01_fp_kind, 0.39525E-01_fp_kind, 0.39200E-01_fp_kind, 0.38862E-01_fp_kind, 0.38513E-01_fp_kind,&
 0.38153E-01_fp_kind, 0.37782E-01_fp_kind, 0.37402E-01_fp_kind, 0.37012E-01_fp_kind, 0.36614E-01_fp_kind,&
 0.36207E-01_fp_kind, 0.35793E-01_fp_kind, 0.35372E-01_fp_kind, 0.34944E-01_fp_kind, 0.34510E-01_fp_kind,&
 0.34744E-01_fp_kind, 0.34289E-01_fp_kind, 0.33830E-01_fp_kind, 0.33365E-01_fp_kind, 0.33547E-01_fp_kind,&
 0.33065E-01_fp_kind, 0.32579E-01_fp_kind, 0.32090E-01_fp_kind, 0.32225E-01_fp_kind, 0.31721E-01_fp_kind,&
 0.31835E-01_fp_kind, 0.31317E-01_fp_kind, 0.30797E-01_fp_kind, 0.30880E-01_fp_kind, 0.30347E-01_fp_kind,&
 0.30412E-01_fp_kind, 0.29868E-01_fp_kind, 0.29915E-01_fp_kind, 0.29360E-01_fp_kind, 0.29389E-01_fp_kind,&
 0.28825E-01_fp_kind, 0.28837E-01_fp_kind, 0.28264E-01_fp_kind, 0.28260E-01_fp_kind, 0.27678E-01_fp_kind/

DATA (sdd(9,j),j=1,100) / &
 0.46363E-01_fp_kind, 0.46985E-01_fp_kind, 0.47964E-01_fp_kind, 0.49421E-01_fp_kind, 0.53062E-01_fp_kind,&
 0.55018E-01_fp_kind, 0.55902E-01_fp_kind, 0.57514E-01_fp_kind, 0.58856E-01_fp_kind, 0.59931E-01_fp_kind,&
 0.60096E-01_fp_kind, 0.60706E-01_fp_kind, 0.61085E-01_fp_kind, 0.61254E-01_fp_kind, 0.61767E-01_fp_kind,&
 0.61547E-01_fp_kind, 0.61673E-01_fp_kind, 0.61147E-01_fp_kind, 0.60967E-01_fp_kind, 0.61106E-01_fp_kind,&
 0.60664E-01_fp_kind, 0.60123E-01_fp_kind, 0.59910E-01_fp_kind, 0.59601E-01_fp_kind, 0.59211E-01_fp_kind,&
 0.60685E-01_fp_kind, 0.58726E-01_fp_kind, 0.58290E-01_fp_kind, 0.57776E-01_fp_kind, 0.57191E-01_fp_kind,&
 0.57987E-01_fp_kind, 0.57250E-01_fp_kind, 0.56466E-01_fp_kind, 0.55639E-01_fp_kind, 0.54777E-01_fp_kind,&
 0.55189E-01_fp_kind, 0.54236E-01_fp_kind, 0.53263E-01_fp_kind, 0.53504E-01_fp_kind, 0.52466E-01_fp_kind,&
 0.52611E-01_fp_kind, 0.51524E-01_fp_kind, 0.51586E-01_fp_kind, 0.50462E-01_fp_kind, 0.50452E-01_fp_kind,&
 0.49303E-01_fp_kind, 0.49230E-01_fp_kind, 0.48066E-01_fp_kind, 0.47939E-01_fp_kind, 0.47784E-01_fp_kind,&
 0.47603E-01_fp_kind, 0.46396E-01_fp_kind, 0.46175E-01_fp_kind, 0.45932E-01_fp_kind, 0.45668E-01_fp_kind,&
 0.44444E-01_fp_kind, 0.44151E-01_fp_kind, 0.43841E-01_fp_kind, 0.43514E-01_fp_kind, 0.43172E-01_fp_kind,&
 0.42815E-01_fp_kind, 0.42445E-01_fp_kind, 0.42061E-01_fp_kind, 0.41665E-01_fp_kind, 0.41258E-01_fp_kind,&
 0.40840E-01_fp_kind, 0.40412E-01_fp_kind, 0.39975E-01_fp_kind, 0.39529E-01_fp_kind, 0.39075E-01_fp_kind,&
 0.38613E-01_fp_kind, 0.38914E-01_fp_kind, 0.38428E-01_fp_kind, 0.37936E-01_fp_kind, 0.37437E-01_fp_kind,&
 0.36934E-01_fp_kind, 0.37158E-01_fp_kind, 0.36635E-01_fp_kind, 0.36107E-01_fp_kind, 0.35576E-01_fp_kind,&
 0.35746E-01_fp_kind, 0.35198E-01_fp_kind, 0.34647E-01_fp_kind, 0.34780E-01_fp_kind, 0.34214E-01_fp_kind,&
 0.34326E-01_fp_kind, 0.33746E-01_fp_kind, 0.33164E-01_fp_kind, 0.33244E-01_fp_kind, 0.32650E-01_fp_kind,&
 0.32709E-01_fp_kind, 0.32104E-01_fp_kind, 0.32144E-01_fp_kind, 0.31529E-01_fp_kind, 0.31551E-01_fp_kind,&
 0.30925E-01_fp_kind, 0.30929E-01_fp_kind, 0.30925E-01_fp_kind, 0.30282E-01_fp_kind, 0.30262E-01_fp_kind/

DATA (sdd(10,j),j=1,100) / &
 0.46588E-01_fp_kind, 0.47102E-01_fp_kind, 0.48724E-01_fp_kind, 0.50841E-01_fp_kind, 0.54640E-01_fp_kind,&
 0.56552E-01_fp_kind, 0.58288E-01_fp_kind, 0.59786E-01_fp_kind, 0.61027E-01_fp_kind, 0.62006E-01_fp_kind,&
 0.62049E-01_fp_kind, 0.62570E-01_fp_kind, 0.63473E-01_fp_kind, 0.63524E-01_fp_kind, 0.63386E-01_fp_kind,&
 0.63618E-01_fp_kind, 0.63659E-01_fp_kind, 0.63532E-01_fp_kind, 0.63257E-01_fp_kind, 0.62854E-01_fp_kind,&
 0.62797E-01_fp_kind, 0.62174E-01_fp_kind, 0.61903E-01_fp_kind, 0.61540E-01_fp_kind, 0.61101E-01_fp_kind,&
 0.61656E-01_fp_kind, 0.61230E-01_fp_kind, 0.60715E-01_fp_kind, 0.60120E-01_fp_kind, 0.59456E-01_fp_kind,&
 0.58730E-01_fp_kind, 0.59428E-01_fp_kind, 0.58562E-01_fp_kind, 0.57657E-01_fp_kind, 0.56717E-01_fp_kind,&
 0.57113E-01_fp_kind, 0.56084E-01_fp_kind, 0.55036E-01_fp_kind, 0.55258E-01_fp_kind, 0.54147E-01_fp_kind,&
 0.54272E-01_fp_kind, 0.53115E-01_fp_kind, 0.53155E-01_fp_kind, 0.51964E-01_fp_kind, 0.51931E-01_fp_kind,&
 0.50718E-01_fp_kind, 0.50622E-01_fp_kind, 0.50495E-01_fp_kind, 0.49247E-01_fp_kind, 0.49070E-01_fp_kind,&
 0.48866E-01_fp_kind, 0.48636E-01_fp_kind, 0.47358E-01_fp_kind, 0.47092E-01_fp_kind, 0.46805E-01_fp_kind,&
 0.46499E-01_fp_kind, 0.46173E-01_fp_kind, 0.45830E-01_fp_kind, 0.45471E-01_fp_kind, 0.45096E-01_fp_kind,&
 0.43791E-01_fp_kind, 0.43399E-01_fp_kind, 0.42994E-01_fp_kind, 0.42577E-01_fp_kind, 0.43018E-01_fp_kind,&
 0.42568E-01_fp_kind, 0.42108E-01_fp_kind, 0.41638E-01_fp_kind, 0.41160E-01_fp_kind, 0.40674E-01_fp_kind,&
 0.40181E-01_fp_kind, 0.39680E-01_fp_kind, 0.39173E-01_fp_kind, 0.39445E-01_fp_kind, 0.38916E-01_fp_kind,&
 0.38381E-01_fp_kind, 0.37842E-01_fp_kind, 0.38054E-01_fp_kind, 0.37495E-01_fp_kind, 0.36933E-01_fp_kind,&
 0.37105E-01_fp_kind, 0.36525E-01_fp_kind, 0.35944E-01_fp_kind, 0.36078E-01_fp_kind, 0.35481E-01_fp_kind,&
 0.34883E-01_fp_kind, 0.34982E-01_fp_kind, 0.34370E-01_fp_kind, 0.34448E-01_fp_kind, 0.33824E-01_fp_kind,&
 0.33881E-01_fp_kind, 0.33245E-01_fp_kind, 0.33283E-01_fp_kind, 0.32637E-01_fp_kind, 0.32655E-01_fp_kind,&
 0.32000E-01_fp_kind, 0.32000E-01_fp_kind, 0.31992E-01_fp_kind, 0.31319E-01_fp_kind, 0.31293E-01_fp_kind/

DATA (sdd(11,j),j=1,100) / &
 0.46377E-01_fp_kind, 0.47979E-01_fp_kind, 0.50789E-01_fp_kind, 0.54962E-01_fp_kind, 0.58333E-01_fp_kind,&
 0.60205E-01_fp_kind, 0.61913E-01_fp_kind, 0.63379E-01_fp_kind, 0.64578E-01_fp_kind, 0.65504E-01_fp_kind,&
 0.66163E-01_fp_kind, 0.66571E-01_fp_kind, 0.67405E-01_fp_kind, 0.67333E-01_fp_kind, 0.67677E-01_fp_kind,&
 0.67221E-01_fp_kind, 0.67177E-01_fp_kind, 0.66966E-01_fp_kind, 0.67130E-01_fp_kind, 0.66632E-01_fp_kind,&
 0.66518E-01_fp_kind, 0.65815E-01_fp_kind, 0.65499E-01_fp_kind, 0.65100E-01_fp_kind, 0.66725E-01_fp_kind,&
 0.66258E-01_fp_kind, 0.65689E-01_fp_kind, 0.65030E-01_fp_kind, 0.64291E-01_fp_kind, 0.63483E-01_fp_kind,&
 0.62614E-01_fp_kind, 0.61694E-01_fp_kind, 0.62288E-01_fp_kind, 0.61241E-01_fp_kind, 0.60164E-01_fp_kind,&
 0.60532E-01_fp_kind, 0.59366E-01_fp_kind, 0.59608E-01_fp_kind, 0.58375E-01_fp_kind, 0.57136E-01_fp_kind,&
 0.57225E-01_fp_kind, 0.57265E-01_fp_kind, 0.55947E-01_fp_kind, 0.55907E-01_fp_kind, 0.54566E-01_fp_kind,&
 0.54458E-01_fp_kind, 0.54314E-01_fp_kind, 0.52939E-01_fp_kind, 0.52741E-01_fp_kind, 0.52514E-01_fp_kind,&
 0.52259E-01_fp_kind, 0.50855E-01_fp_kind, 0.50562E-01_fp_kind, 0.50246E-01_fp_kind, 0.49908E-01_fp_kind,&
 0.49550E-01_fp_kind, 0.49174E-01_fp_kind, 0.48779E-01_fp_kind, 0.48368E-01_fp_kind, 0.47941E-01_fp_kind,&
 0.47500E-01_fp_kind, 0.47045E-01_fp_kind, 0.46577E-01_fp_kind, 0.46098E-01_fp_kind, 0.45607E-01_fp_kind,&
 0.45106E-01_fp_kind, 0.44595E-01_fp_kind, 0.44076E-01_fp_kind, 0.43548E-01_fp_kind, 0.43012E-01_fp_kind,&
 0.42470E-01_fp_kind, 0.42784E-01_fp_kind, 0.42216E-01_fp_kind, 0.41642E-01_fp_kind, 0.41063E-01_fp_kind,&
 0.41310E-01_fp_kind, 0.40710E-01_fp_kind, 0.40106E-01_fp_kind, 0.40308E-01_fp_kind, 0.39686E-01_fp_kind,&
 0.39060E-01_fp_kind, 0.39221E-01_fp_kind, 0.38579E-01_fp_kind, 0.37935E-01_fp_kind, 0.38056E-01_fp_kind,&
 0.37398E-01_fp_kind, 0.37496E-01_fp_kind, 0.36824E-01_fp_kind, 0.36899E-01_fp_kind, 0.36215E-01_fp_kind,&
 0.36269E-01_fp_kind, 0.35573E-01_fp_kind, 0.35606E-01_fp_kind, 0.34900E-01_fp_kind, 0.34912E-01_fp_kind,&
 0.34197E-01_fp_kind, 0.34190E-01_fp_kind, 0.34174E-01_fp_kind, 0.33440E-01_fp_kind, 0.33406E-01_fp_kind/

DATA (sdd(12,j),j=1,100) / &
 0.46649E-01_fp_kind, 0.48763E-01_fp_kind, 0.54884E-01_fp_kind, 0.56655E-01_fp_kind, 0.60105E-01_fp_kind,&
 0.62009E-01_fp_kind, 0.63743E-01_fp_kind, 0.65227E-01_fp_kind, 0.66433E-01_fp_kind, 0.67358E-01_fp_kind,&
 0.68009E-01_fp_kind, 0.68401E-01_fp_kind, 0.69232E-01_fp_kind, 0.69134E-01_fp_kind, 0.69466E-01_fp_kind,&
 0.69577E-01_fp_kind, 0.69496E-01_fp_kind, 0.69247E-01_fp_kind, 0.68854E-01_fp_kind, 0.68341E-01_fp_kind,&
 0.68227E-01_fp_kind, 0.67998E-01_fp_kind, 0.67673E-01_fp_kind, 0.67725E-01_fp_kind, 0.68820E-01_fp_kind,&
 0.68289E-01_fp_kind, 0.67657E-01_fp_kind, 0.66934E-01_fp_kind, 0.66131E-01_fp_kind, 0.65259E-01_fp_kind,&
 0.64328E-01_fp_kind, 0.65004E-01_fp_kind, 0.63931E-01_fp_kind, 0.62822E-01_fp_kind, 0.61684E-01_fp_kind,&
 0.62041E-01_fp_kind, 0.60815E-01_fp_kind, 0.61044E-01_fp_kind, 0.59753E-01_fp_kind, 0.59871E-01_fp_kind,&
 0.58532E-01_fp_kind, 0.58556E-01_fp_kind, 0.57184E-01_fp_kind, 0.57128E-01_fp_kind, 0.57031E-01_fp_kind,&
 0.55611E-01_fp_kind, 0.55450E-01_fp_kind, 0.55256E-01_fp_kind, 0.53812E-01_fp_kind, 0.53568E-01_fp_kind,&
 0.53296E-01_fp_kind, 0.52997E-01_fp_kind, 0.52674E-01_fp_kind, 0.52328E-01_fp_kind, 0.50848E-01_fp_kind,&
 0.50473E-01_fp_kind, 0.50079E-01_fp_kind, 0.49668E-01_fp_kind, 0.49239E-01_fp_kind, 0.48795E-01_fp_kind,&
 0.48337E-01_fp_kind, 0.47865E-01_fp_kind, 0.47380E-01_fp_kind, 0.46883E-01_fp_kind, 0.46376E-01_fp_kind,&
 0.45858E-01_fp_kind, 0.46278E-01_fp_kind, 0.45728E-01_fp_kind, 0.45170E-01_fp_kind, 0.44604E-01_fp_kind,&
 0.44032E-01_fp_kind, 0.43453E-01_fp_kind, 0.43754E-01_fp_kind, 0.43150E-01_fp_kind, 0.42542E-01_fp_kind,&
 0.41929E-01_fp_kind, 0.42163E-01_fp_kind, 0.41529E-01_fp_kind, 0.40892E-01_fp_kind, 0.41082E-01_fp_kind,&
 0.40426E-01_fp_kind, 0.39769E-01_fp_kind, 0.39916E-01_fp_kind, 0.39243E-01_fp_kind, 0.39365E-01_fp_kind,&
 0.38677E-01_fp_kind, 0.37988E-01_fp_kind, 0.38073E-01_fp_kind, 0.37371E-01_fp_kind, 0.37433E-01_fp_kind,&
 0.36720E-01_fp_kind, 0.36760E-01_fp_kind, 0.36035E-01_fp_kind, 0.36054E-01_fp_kind, 0.36063E-01_fp_kind,&
 0.35319E-01_fp_kind, 0.35308E-01_fp_kind, 0.34554E-01_fp_kind, 0.34525E-01_fp_kind, 0.34486E-01_fp_kind/

DATA (sdd(13,j),j=1,100) / &
 0.47337E-01_fp_kind, 0.50407E-01_fp_kind, 0.57899E-01_fp_kind, 0.59865E-01_fp_kind, 0.63558E-01_fp_kind,&
 0.65595E-01_fp_kind, 0.67436E-01_fp_kind, 0.69000E-01_fp_kind, 0.70262E-01_fp_kind, 0.71220E-01_fp_kind,&
 0.71885E-01_fp_kind, 0.72276E-01_fp_kind, 0.72415E-01_fp_kind, 0.73009E-01_fp_kind, 0.73344E-01_fp_kind,&
 0.72819E-01_fp_kind, 0.72753E-01_fp_kind, 0.72517E-01_fp_kind, 0.72700E-01_fp_kind, 0.72180E-01_fp_kind,&
 0.71563E-01_fp_kind, 0.71376E-01_fp_kind, 0.71096E-01_fp_kind, 0.73006E-01_fp_kind, 0.72484E-01_fp_kind,&
 0.71844E-01_fp_kind, 0.71101E-01_fp_kind, 0.70266E-01_fp_kind, 0.69353E-01_fp_kind, 0.68371E-01_fp_kind,&
 0.69138E-01_fp_kind, 0.67996E-01_fp_kind, 0.66813E-01_fp_kind, 0.65597E-01_fp_kind, 0.66006E-01_fp_kind,&
 0.64692E-01_fp_kind, 0.64958E-01_fp_kind, 0.63570E-01_fp_kind, 0.63714E-01_fp_kind, 0.62273E-01_fp_kind,&
 0.62313E-01_fp_kind, 0.60836E-01_fp_kind, 0.60786E-01_fp_kind, 0.60692E-01_fp_kind, 0.59163E-01_fp_kind,&
 0.58999E-01_fp_kind, 0.58797E-01_fp_kind, 0.58560E-01_fp_kind, 0.56988E-01_fp_kind, 0.56701E-01_fp_kind,&
 0.56387E-01_fp_kind, 0.56045E-01_fp_kind, 0.55678E-01_fp_kind, 0.54087E-01_fp_kind, 0.53689E-01_fp_kind,&
 0.53271E-01_fp_kind, 0.52833E-01_fp_kind, 0.52378E-01_fp_kind, 0.51906E-01_fp_kind, 0.51418E-01_fp_kind,&
 0.50915E-01_fp_kind, 0.50399E-01_fp_kind, 0.49870E-01_fp_kind, 0.49329E-01_fp_kind, 0.48778E-01_fp_kind,&
 0.49235E-01_fp_kind, 0.48649E-01_fp_kind, 0.48054E-01_fp_kind, 0.47452E-01_fp_kind, 0.46841E-01_fp_kind,&
 0.46224E-01_fp_kind, 0.46554E-01_fp_kind, 0.45910E-01_fp_kind, 0.45262E-01_fp_kind, 0.44608E-01_fp_kind,&
 0.44865E-01_fp_kind, 0.44189E-01_fp_kind, 0.43511E-01_fp_kind, 0.43719E-01_fp_kind, 0.43020E-01_fp_kind,&
 0.42320E-01_fp_kind, 0.42483E-01_fp_kind, 0.41765E-01_fp_kind, 0.41901E-01_fp_kind, 0.41167E-01_fp_kind,&
 0.41277E-01_fp_kind, 0.40529E-01_fp_kind, 0.39782E-01_fp_kind, 0.39852E-01_fp_kind, 0.39912E-01_fp_kind,&
 0.39139E-01_fp_kind, 0.39176E-01_fp_kind, 0.38392E-01_fp_kind, 0.38406E-01_fp_kind, 0.37613E-01_fp_kind,&
 0.37606E-01_fp_kind, 0.37589E-01_fp_kind, 0.36775E-01_fp_kind, 0.36738E-01_fp_kind, 0.35917E-01_fp_kind/

DATA (sdd(14,j),j=1,100) / &
 0.47988E-01_fp_kind, 0.54397E-01_fp_kind, 0.60890E-01_fp_kind, 0.63126E-01_fp_kind, 0.65663E-01_fp_kind,&
 0.69325E-01_fp_kind, 0.70174E-01_fp_kind, 0.71948E-01_fp_kind, 0.73371E-01_fp_kind, 0.74453E-01_fp_kind,&
 0.75212E-01_fp_kind, 0.75671E-01_fp_kind, 0.76611E-01_fp_kind, 0.76522E-01_fp_kind, 0.76225E-01_fp_kind,&
 0.76403E-01_fp_kind, 0.76378E-01_fp_kind, 0.76178E-01_fp_kind, 0.75835E-01_fp_kind, 0.75373E-01_fp_kind,&
 0.75360E-01_fp_kind, 0.74712E-01_fp_kind, 0.76578E-01_fp_kind, 0.76105E-01_fp_kind, 0.75498E-01_fp_kind,&
 0.74770E-01_fp_kind, 0.73938E-01_fp_kind, 0.73014E-01_fp_kind, 0.72011E-01_fp_kind, 0.72889E-01_fp_kind,&
 0.71705E-01_fp_kind, 0.70473E-01_fp_kind, 0.71036E-01_fp_kind, 0.69678E-01_fp_kind, 0.68296E-01_fp_kind,&
 0.68614E-01_fp_kind, 0.67149E-01_fp_kind, 0.67330E-01_fp_kind, 0.65805E-01_fp_kind, 0.65870E-01_fp_kind,&
 0.65879E-01_fp_kind, 0.64272E-01_fp_kind, 0.64189E-01_fp_kind, 0.62565E-01_fp_kind, 0.62406E-01_fp_kind,&
 0.62206E-01_fp_kind, 0.61968E-01_fp_kind, 0.60295E-01_fp_kind, 0.60002E-01_fp_kind, 0.59678E-01_fp_kind,&
 0.59325E-01_fp_kind, 0.58945E-01_fp_kind, 0.58538E-01_fp_kind, 0.56837E-01_fp_kind, 0.56400E-01_fp_kind,&
 0.55942E-01_fp_kind, 0.55465E-01_fp_kind, 0.54970E-01_fp_kind, 0.54458E-01_fp_kind, 0.53930E-01_fp_kind,&
 0.53387E-01_fp_kind, 0.52830E-01_fp_kind, 0.52261E-01_fp_kind, 0.52787E-01_fp_kind, 0.52179E-01_fp_kind,&
 0.51561E-01_fp_kind, 0.50933E-01_fp_kind, 0.50297E-01_fp_kind, 0.49652E-01_fp_kind, 0.50035E-01_fp_kind,&
 0.49361E-01_fp_kind, 0.48681E-01_fp_kind, 0.47995E-01_fp_kind, 0.48297E-01_fp_kind, 0.47586E-01_fp_kind,&
 0.46872E-01_fp_kind, 0.46154E-01_fp_kind, 0.46383E-01_fp_kind, 0.45644E-01_fp_kind, 0.44903E-01_fp_kind,&
 0.45083E-01_fp_kind, 0.44324E-01_fp_kind, 0.44475E-01_fp_kind, 0.43699E-01_fp_kind, 0.43821E-01_fp_kind,&
 0.43030E-01_fp_kind, 0.42238E-01_fp_kind, 0.42320E-01_fp_kind, 0.42389E-01_fp_kind, 0.41571E-01_fp_kind,&
 0.41615E-01_fp_kind, 0.40785E-01_fp_kind, 0.40806E-01_fp_kind, 0.39965E-01_fp_kind, 0.39963E-01_fp_kind,&
 0.39112E-01_fp_kind, 0.39088E-01_fp_kind, 0.39053E-01_fp_kind, 0.38183E-01_fp_kind, 0.38127E-01_fp_kind/

DATA (sdd(15,j),j=1,100) / &
 0.48891E-01_fp_kind, 0.58705E-01_fp_kind, 0.63081E-01_fp_kind, 0.65810E-01_fp_kind, 0.68701E-01_fp_kind,&
 0.71373E-01_fp_kind, 0.73701E-01_fp_kind, 0.75645E-01_fp_kind, 0.77204E-01_fp_kind, 0.78390E-01_fp_kind,&
 0.78362E-01_fp_kind, 0.78928E-01_fp_kind, 0.79982E-01_fp_kind, 0.79962E-01_fp_kind, 0.79723E-01_fp_kind,&
 0.79976E-01_fp_kind, 0.80019E-01_fp_kind, 0.79256E-01_fp_kind, 0.79000E-01_fp_kind, 0.79206E-01_fp_kind,&
 0.78717E-01_fp_kind, 0.78161E-01_fp_kind, 0.79126E-01_fp_kind, 0.78592E-01_fp_kind, 0.77919E-01_fp_kind,&
 0.77125E-01_fp_kind, 0.78426E-01_fp_kind, 0.77373E-01_fp_kind, 0.76241E-01_fp_kind, 0.75042E-01_fp_kind,&
 0.75807E-01_fp_kind, 0.74445E-01_fp_kind, 0.73046E-01_fp_kind, 0.73511E-01_fp_kind, 0.72001E-01_fp_kind,&
 0.72302E-01_fp_kind, 0.70711E-01_fp_kind, 0.70871E-01_fp_kind, 0.69223E-01_fp_kind, 0.69264E-01_fp_kind,&
 0.67578E-01_fp_kind, 0.67518E-01_fp_kind, 0.67408E-01_fp_kind, 0.65668E-01_fp_kind, 0.65479E-01_fp_kind,&
 0.65247E-01_fp_kind, 0.64977E-01_fp_kind, 0.63193E-01_fp_kind, 0.62868E-01_fp_kind, 0.62511E-01_fp_kind,&
 0.62123E-01_fp_kind, 0.61708E-01_fp_kind, 0.61266E-01_fp_kind, 0.60800E-01_fp_kind, 0.58990E-01_fp_kind,&
 0.58497E-01_fp_kind, 0.57985E-01_fp_kind, 0.57453E-01_fp_kind, 0.56905E-01_fp_kind, 0.56340E-01_fp_kind,&
 0.55761E-01_fp_kind, 0.56364E-01_fp_kind, 0.55740E-01_fp_kind, 0.55105E-01_fp_kind, 0.54458E-01_fp_kind,&
 0.53801E-01_fp_kind, 0.53135E-01_fp_kind, 0.52460E-01_fp_kind, 0.52878E-01_fp_kind, 0.52171E-01_fp_kind,&
 0.51458E-01_fp_kind, 0.50738E-01_fp_kind, 0.51069E-01_fp_kind, 0.50323E-01_fp_kind, 0.49572E-01_fp_kind,&
 0.48818E-01_fp_kind, 0.49070E-01_fp_kind, 0.48293E-01_fp_kind, 0.47514E-01_fp_kind, 0.47714E-01_fp_kind,&
 0.46915E-01_fp_kind, 0.47084E-01_fp_kind, 0.46266E-01_fp_kind, 0.46405E-01_fp_kind, 0.45571E-01_fp_kind,&
 0.44737E-01_fp_kind, 0.44831E-01_fp_kind, 0.43982E-01_fp_kind, 0.44049E-01_fp_kind, 0.43188E-01_fp_kind,&
 0.43228E-01_fp_kind, 0.43258E-01_fp_kind, 0.42370E-01_fp_kind, 0.42375E-01_fp_kind, 0.41477E-01_fp_kind,&
 0.41458E-01_fp_kind, 0.41428E-01_fp_kind, 0.40508E-01_fp_kind, 0.40456E-01_fp_kind, 0.40392E-01_fp_kind/

DATA (sdd(16,j),j=1,100) / &
 0.50895E-01_fp_kind, 0.63162E-01_fp_kind, 0.65839E-01_fp_kind, 0.71307E-01_fp_kind, 0.74545E-01_fp_kind,&
 0.76130E-01_fp_kind, 0.78842E-01_fp_kind, 0.79971E-01_fp_kind, 0.81855E-01_fp_kind, 0.82340E-01_fp_kind,&
 0.83447E-01_fp_kind, 0.84191E-01_fp_kind, 0.84614E-01_fp_kind, 0.84757E-01_fp_kind, 0.84661E-01_fp_kind,&
 0.85078E-01_fp_kind, 0.84587E-01_fp_kind, 0.84624E-01_fp_kind, 0.83883E-01_fp_kind, 0.83677E-01_fp_kind,&
 0.83381E-01_fp_kind, 0.84927E-01_fp_kind, 0.84435E-01_fp_kind, 0.83781E-01_fp_kind, 0.82984E-01_fp_kind,&
 0.82062E-01_fp_kind, 0.83396E-01_fp_kind, 0.82206E-01_fp_kind, 0.80936E-01_fp_kind, 0.79601E-01_fp_kind,&
 0.80372E-01_fp_kind, 0.78869E-01_fp_kind, 0.77334E-01_fp_kind, 0.77791E-01_fp_kind, 0.76146E-01_fp_kind,&
 0.76432E-01_fp_kind, 0.74707E-01_fp_kind, 0.74848E-01_fp_kind, 0.74919E-01_fp_kind, 0.73086E-01_fp_kind,&
 0.73044E-01_fp_kind, 0.71188E-01_fp_kind, 0.71049E-01_fp_kind, 0.70861E-01_fp_kind, 0.70626E-01_fp_kind,&
 0.68706E-01_fp_kind, 0.68403E-01_fp_kind, 0.68063E-01_fp_kind, 0.67686E-01_fp_kind, 0.67276E-01_fp_kind,&
 0.65329E-01_fp_kind, 0.64878E-01_fp_kind, 0.64400E-01_fp_kind, 0.63896E-01_fp_kind, 0.63369E-01_fp_kind,&
 0.62820E-01_fp_kind, 0.62251E-01_fp_kind, 0.61662E-01_fp_kind, 0.61056E-01_fp_kind, 0.60433E-01_fp_kind,&
 0.59795E-01_fp_kind, 0.59142E-01_fp_kind, 0.58477E-01_fp_kind, 0.59051E-01_fp_kind, 0.58343E-01_fp_kind,&
 0.57625E-01_fp_kind, 0.56897E-01_fp_kind, 0.56160E-01_fp_kind, 0.55416E-01_fp_kind, 0.55830E-01_fp_kind,&
 0.55053E-01_fp_kind, 0.54270E-01_fp_kind, 0.53482E-01_fp_kind, 0.53805E-01_fp_kind, 0.52990E-01_fp_kind,&
 0.52171E-01_fp_kind, 0.52434E-01_fp_kind, 0.51591E-01_fp_kind, 0.50746E-01_fp_kind, 0.50953E-01_fp_kind,&
 0.50087E-01_fp_kind, 0.50261E-01_fp_kind, 0.49375E-01_fp_kind, 0.49516E-01_fp_kind, 0.48613E-01_fp_kind,&
 0.47710E-01_fp_kind, 0.47804E-01_fp_kind, 0.47884E-01_fp_kind, 0.46950E-01_fp_kind, 0.47002E-01_fp_kind,&
 0.46055E-01_fp_kind, 0.46079E-01_fp_kind, 0.45119E-01_fp_kind, 0.45117E-01_fp_kind, 0.45102E-01_fp_kind,&
 0.44118E-01_fp_kind, 0.44078E-01_fp_kind, 0.43085E-01_fp_kind, 0.43021E-01_fp_kind, 0.42945E-01_fp_kind/

DATA (sdd(17,j),j=1,100) / &
 0.55476E-01_fp_kind, 0.64634E-01_fp_kind, 0.68113E-01_fp_kind, 0.74147E-01_fp_kind, 0.76142E-01_fp_kind,&
 0.79603E-01_fp_kind, 0.81289E-01_fp_kind, 0.83843E-01_fp_kind, 0.84820E-01_fp_kind, 0.85477E-01_fp_kind,&
 0.86752E-01_fp_kind, 0.87637E-01_fp_kind, 0.87340E-01_fp_kind, 0.87627E-01_fp_kind, 0.87662E-01_fp_kind,&
 0.88216E-01_fp_kind, 0.87840E-01_fp_kind, 0.87334E-01_fp_kind, 0.87371E-01_fp_kind, 0.87291E-01_fp_kind,&
 0.87123E-01_fp_kind, 0.88958E-01_fp_kind, 0.88385E-01_fp_kind, 0.87645E-01_fp_kind, 0.86759E-01_fp_kind,&
 0.85745E-01_fp_kind, 0.84623E-01_fp_kind, 0.85817E-01_fp_kind, 0.84449E-01_fp_kind, 0.83016E-01_fp_kind,&
 0.83794E-01_fp_kind, 0.82191E-01_fp_kind, 0.80557E-01_fp_kind, 0.81012E-01_fp_kind, 0.79268E-01_fp_kind,&
 0.79547E-01_fp_kind, 0.77724E-01_fp_kind, 0.77854E-01_fp_kind, 0.75978E-01_fp_kind, 0.75983E-01_fp_kind,&
 0.75923E-01_fp_kind, 0.73974E-01_fp_kind, 0.73817E-01_fp_kind, 0.73609E-01_fp_kind, 0.73353E-01_fp_kind,&
 0.71342E-01_fp_kind, 0.71018E-01_fp_kind, 0.70654E-01_fp_kind, 0.70254E-01_fp_kind, 0.69819E-01_fp_kind,&
 0.69352E-01_fp_kind, 0.67309E-01_fp_kind, 0.66805E-01_fp_kind, 0.66275E-01_fp_kind, 0.65721E-01_fp_kind,&
 0.65144E-01_fp_kind, 0.64547E-01_fp_kind, 0.63929E-01_fp_kind, 0.63294E-01_fp_kind, 0.62642E-01_fp_kind,&
 0.61974E-01_fp_kind, 0.61292E-01_fp_kind, 0.61917E-01_fp_kind, 0.61188E-01_fp_kind, 0.60448E-01_fp_kind,&
 0.59698E-01_fp_kind, 0.58938E-01_fp_kind, 0.58169E-01_fp_kind, 0.58622E-01_fp_kind, 0.57818E-01_fp_kind,&
 0.57007E-01_fp_kind, 0.56190E-01_fp_kind, 0.56546E-01_fp_kind, 0.55700E-01_fp_kind, 0.54849E-01_fp_kind,&
 0.55141E-01_fp_kind, 0.54264E-01_fp_kind, 0.53385E-01_fp_kind, 0.53616E-01_fp_kind, 0.52714E-01_fp_kind,&
 0.52910E-01_fp_kind, 0.51987E-01_fp_kind, 0.51063E-01_fp_kind, 0.51206E-01_fp_kind, 0.50264E-01_fp_kind,&
 0.50374E-01_fp_kind, 0.49415E-01_fp_kind, 0.49494E-01_fp_kind, 0.48520E-01_fp_kind, 0.48569E-01_fp_kind,&
 0.48604E-01_fp_kind, 0.47600E-01_fp_kind, 0.47608E-01_fp_kind, 0.46592E-01_fp_kind, 0.46572E-01_fp_kind,&
 0.46539E-01_fp_kind, 0.45498E-01_fp_kind, 0.45440E-01_fp_kind, 0.45369E-01_fp_kind, 0.44306E-01_fp_kind/

DATA (sdd(18,j),j=1,100) / &
 0.58744E-01_fp_kind, 0.69111E-01_fp_kind, 0.73141E-01_fp_kind, 0.77740E-01_fp_kind, 0.80361E-01_fp_kind,&
 0.82891E-01_fp_kind, 0.86408E-01_fp_kind, 0.88103E-01_fp_kind, 0.89409E-01_fp_kind, 0.90332E-01_fp_kind,&
 0.90897E-01_fp_kind, 0.92052E-01_fp_kind, 0.91962E-01_fp_kind, 0.92461E-01_fp_kind, 0.92689E-01_fp_kind,&
 0.92695E-01_fp_kind, 0.92525E-01_fp_kind, 0.92220E-01_fp_kind, 0.91818E-01_fp_kind, 0.91984E-01_fp_kind,&
 0.93400E-01_fp_kind, 0.92958E-01_fp_kind, 0.92319E-01_fp_kind, 0.91508E-01_fp_kind, 0.90547E-01_fp_kind,&
 0.92135E-01_fp_kind, 0.90853E-01_fp_kind, 0.89477E-01_fp_kind, 0.88022E-01_fp_kind, 0.88948E-01_fp_kind,&
 0.87295E-01_fp_kind, 0.85603E-01_fp_kind, 0.86163E-01_fp_kind, 0.84341E-01_fp_kind, 0.84702E-01_fp_kind,&
 0.82787E-01_fp_kind, 0.82980E-01_fp_kind, 0.81001E-01_fp_kind, 0.81052E-01_fp_kind, 0.81033E-01_fp_kind,&
 0.78966E-01_fp_kind, 0.78836E-01_fp_kind, 0.78649E-01_fp_kind, 0.76539E-01_fp_kind, 0.76268E-01_fp_kind,&
 0.75950E-01_fp_kind, 0.75588E-01_fp_kind, 0.75185E-01_fp_kind, 0.73028E-01_fp_kind, 0.72573E-01_fp_kind,&
 0.72085E-01_fp_kind, 0.71566E-01_fp_kind, 0.71018E-01_fp_kind, 0.70443E-01_fp_kind, 0.69843E-01_fp_kind,&
 0.69220E-01_fp_kind, 0.68575E-01_fp_kind, 0.67909E-01_fp_kind, 0.67225E-01_fp_kind, 0.66523E-01_fp_kind,&
 0.65804E-01_fp_kind, 0.65071E-01_fp_kind, 0.64324E-01_fp_kind, 0.64948E-01_fp_kind, 0.64154E-01_fp_kind,&
 0.63350E-01_fp_kind, 0.62535E-01_fp_kind, 0.61711E-01_fp_kind, 0.60879E-01_fp_kind, 0.61326E-01_fp_kind,&
 0.60458E-01_fp_kind, 0.59584E-01_fp_kind, 0.59957E-01_fp_kind, 0.59051E-01_fp_kind, 0.58141E-01_fp_kind,&
 0.58446E-01_fp_kind, 0.57509E-01_fp_kind, 0.56568E-01_fp_kind, 0.56810E-01_fp_kind, 0.55845E-01_fp_kind,&
 0.54879E-01_fp_kind, 0.55061E-01_fp_kind, 0.54073E-01_fp_kind, 0.54219E-01_fp_kind, 0.53212E-01_fp_kind,&
 0.53323E-01_fp_kind, 0.52298E-01_fp_kind, 0.52376E-01_fp_kind, 0.51335E-01_fp_kind, 0.51381E-01_fp_kind,&
 0.51413E-01_fp_kind, 0.50340E-01_fp_kind, 0.50341E-01_fp_kind, 0.49255E-01_fp_kind, 0.49227E-01_fp_kind,&
 0.49186E-01_fp_kind, 0.48073E-01_fp_kind, 0.48004E-01_fp_kind, 0.47922E-01_fp_kind, 0.46785E-01_fp_kind/

DATA (sdd(19,j),j=1,100) / &
 0.63745E-01_fp_kind, 0.71144E-01_fp_kind, 0.76434E-01_fp_kind, 0.81856E-01_fp_kind, 0.85024E-01_fp_kind,&
 0.87979E-01_fp_kind, 0.90532E-01_fp_kind, 0.92623E-01_fp_kind, 0.93109E-01_fp_kind, 0.94372E-01_fp_kind,&
 0.95224E-01_fp_kind, 0.96655E-01_fp_kind, 0.96780E-01_fp_kind, 0.96648E-01_fp_kind, 0.97120E-01_fp_kind,&
 0.96584E-01_fp_kind, 0.96670E-01_fp_kind, 0.96616E-01_fp_kind, 0.96464E-01_fp_kind, 0.97546E-01_fp_kind,&
 0.99831E-01_fp_kind, 0.99280E-01_fp_kind, 0.98524E-01_fp_kind, 0.97588E-01_fp_kind, 0.96498E-01_fp_kind,&
 0.95273E-01_fp_kind, 0.93935E-01_fp_kind, 0.95203E-01_fp_kind, 0.93603E-01_fp_kind, 0.91938E-01_fp_kind,&
 0.92752E-01_fp_kind, 0.90912E-01_fp_kind, 0.89043E-01_fp_kind, 0.89508E-01_fp_kind, 0.87528E-01_fp_kind,&
 0.87804E-01_fp_kind, 0.87988E-01_fp_kind, 0.85861E-01_fp_kind, 0.85898E-01_fp_kind, 0.83735E-01_fp_kind,&
 0.83647E-01_fp_kind, 0.83496E-01_fp_kind, 0.81277E-01_fp_kind, 0.81031E-01_fp_kind, 0.80732E-01_fp_kind,&
 0.80384E-01_fp_kind, 0.79991E-01_fp_kind, 0.77711E-01_fp_kind, 0.77258E-01_fp_kind, 0.76768E-01_fp_kind,&
 0.76244E-01_fp_kind, 0.75687E-01_fp_kind, 0.75100E-01_fp_kind, 0.74485E-01_fp_kind, 0.73844E-01_fp_kind,&
 0.73178E-01_fp_kind, 0.72490E-01_fp_kind, 0.71780E-01_fp_kind, 0.71051E-01_fp_kind, 0.70303E-01_fp_kind,&
 0.69539E-01_fp_kind, 0.68758E-01_fp_kind, 0.67963E-01_fp_kind, 0.67154E-01_fp_kind, 0.67776E-01_fp_kind,&
 0.66921E-01_fp_kind, 0.66055E-01_fp_kind, 0.65179E-01_fp_kind, 0.64294E-01_fp_kind, 0.64764E-01_fp_kind,&
 0.63842E-01_fp_kind, 0.62913E-01_fp_kind, 0.61977E-01_fp_kind, 0.62342E-01_fp_kind, 0.61375E-01_fp_kind,&
 0.60404E-01_fp_kind, 0.60697E-01_fp_kind, 0.59698E-01_fp_kind, 0.59949E-01_fp_kind, 0.58924E-01_fp_kind,&
 0.57897E-01_fp_kind, 0.58085E-01_fp_kind, 0.57036E-01_fp_kind, 0.57185E-01_fp_kind, 0.56115E-01_fp_kind,&
 0.56228E-01_fp_kind, 0.55138E-01_fp_kind, 0.55215E-01_fp_kind, 0.54108E-01_fp_kind, 0.54151E-01_fp_kind,&
 0.54179E-01_fp_kind, 0.53038E-01_fp_kind, 0.53034E-01_fp_kind, 0.51878E-01_fp_kind, 0.51843E-01_fp_kind,&
 0.51793E-01_fp_kind, 0.50609E-01_fp_kind, 0.50529E-01_fp_kind, 0.50437E-01_fp_kind, 0.49226E-01_fp_kind/

DATA (sdd(20,j),j=1,100) / &
 0.67533E-01_fp_kind, 0.71480E-01_fp_kind, 0.77854E-01_fp_kind, 0.83961E-01_fp_kind, 0.87599E-01_fp_kind,&
 0.90910E-01_fp_kind, 0.92360E-01_fp_kind, 0.94796E-01_fp_kind, 0.96705E-01_fp_kind, 0.97042E-01_fp_kind,&
 0.98091E-01_fp_kind, 0.98751E-01_fp_kind, 0.99080E-01_fp_kind, 0.99998E-01_fp_kind, 0.99790E-01_fp_kind,&
 0.99419E-01_fp_kind, 0.99676E-01_fp_kind, 0.99791E-01_fp_kind, 0.99127E-01_fp_kind, 0.10311E+00_fp_kind,&
 0.10276E+00_fp_kind, 0.10217E+00_fp_kind, 0.10137E+00_fp_kind, 0.10039E+00_fp_kind, 0.99256E-01_fp_kind,&
 0.97982E-01_fp_kind, 0.96592E-01_fp_kind, 0.97887E-01_fp_kind, 0.96230E-01_fp_kind, 0.94509E-01_fp_kind,&
 0.95339E-01_fp_kind, 0.93438E-01_fp_kind, 0.94018E-01_fp_kind, 0.91985E-01_fp_kind, 0.92351E-01_fp_kind,&
 0.90225E-01_fp_kind, 0.90412E-01_fp_kind, 0.88223E-01_fp_kind, 0.88259E-01_fp_kind, 0.88219E-01_fp_kind,&
 0.85944E-01_fp_kind, 0.85787E-01_fp_kind, 0.85569E-01_fp_kind, 0.83254E-01_fp_kind, 0.82947E-01_fp_kind,&
 0.82590E-01_fp_kind, 0.82186E-01_fp_kind, 0.81739E-01_fp_kind, 0.79380E-01_fp_kind, 0.78877E-01_fp_kind,&
 0.78339E-01_fp_kind, 0.77768E-01_fp_kind, 0.77166E-01_fp_kind, 0.76534E-01_fp_kind, 0.75876E-01_fp_kind,&
 0.75193E-01_fp_kind, 0.74486E-01_fp_kind, 0.73758E-01_fp_kind, 0.73009E-01_fp_kind, 0.72241E-01_fp_kind,&
 0.71455E-01_fp_kind, 0.70653E-01_fp_kind, 0.69836E-01_fp_kind, 0.70511E-01_fp_kind, 0.69643E-01_fp_kind,&
 0.68763E-01_fp_kind, 0.67873E-01_fp_kind, 0.66972E-01_fp_kind, 0.67485E-01_fp_kind, 0.66543E-01_fp_kind,&
 0.65594E-01_fp_kind, 0.64637E-01_fp_kind, 0.65038E-01_fp_kind, 0.64047E-01_fp_kind, 0.63051E-01_fp_kind,&
 0.63377E-01_fp_kind, 0.62350E-01_fp_kind, 0.61320E-01_fp_kind, 0.61576E-01_fp_kind, 0.60519E-01_fp_kind,&
 0.60732E-01_fp_kind, 0.59650E-01_fp_kind, 0.59823E-01_fp_kind, 0.58718E-01_fp_kind, 0.58852E-01_fp_kind,&
 0.57726E-01_fp_kind, 0.57822E-01_fp_kind, 0.56677E-01_fp_kind, 0.56736E-01_fp_kind, 0.55573E-01_fp_kind,&
 0.55598E-01_fp_kind, 0.54418E-01_fp_kind, 0.54410E-01_fp_kind, 0.54386E-01_fp_kind, 0.53174E-01_fp_kind,&
 0.53118E-01_fp_kind, 0.53047E-01_fp_kind, 0.51806E-01_fp_kind, 0.51705E-01_fp_kind, 0.51590E-01_fp_kind/

DATA (sdd(21,j),j=1,100) / &
 0.68364E-01_fp_kind, 0.74260E-01_fp_kind, 0.81647E-01_fp_kind, 0.86336E-01_fp_kind, 0.90788E-01_fp_kind,&
 0.94713E-01_fp_kind, 0.96605E-01_fp_kind, 0.99434E-01_fp_kind, 0.10046E+00_fp_kind, 0.10112E+00_fp_kind,&
 0.10247E+00_fp_kind, 0.10339E+00_fp_kind, 0.10396E+00_fp_kind, 0.10423E+00_fp_kind, 0.10427E+00_fp_kind,&
 0.10413E+00_fp_kind, 0.10388E+00_fp_kind, 0.10355E+00_fp_kind, 0.10388E+00_fp_kind, 0.10528E+00_fp_kind,&
 0.10494E+00_fp_kind, 0.10436E+00_fp_kind, 0.10357E+00_fp_kind, 0.10579E+00_fp_kind, 0.10455E+00_fp_kind,&
 0.10317E+00_fp_kind, 0.10167E+00_fp_kind, 0.10008E+00_fp_kind, 0.10124E+00_fp_kind, 0.99407E-01_fp_kind,&
 0.10026E+00_fp_kind, 0.98243E-01_fp_kind, 0.96197E-01_fp_kind, 0.96683E-01_fp_kind, 0.94523E-01_fp_kind,&
 0.94807E-01_fp_kind, 0.94994E-01_fp_kind, 0.92683E-01_fp_kind, 0.92713E-01_fp_kind, 0.90367E-01_fp_kind,&
 0.90266E-01_fp_kind, 0.90097E-01_fp_kind, 0.87696E-01_fp_kind, 0.87426E-01_fp_kind, 0.87100E-01_fp_kind,&
 0.86722E-01_fp_kind, 0.86296E-01_fp_kind, 0.83834E-01_fp_kind, 0.83344E-01_fp_kind, 0.82815E-01_fp_kind,&
 0.82248E-01_fp_kind, 0.81647E-01_fp_kind, 0.81014E-01_fp_kind, 0.80350E-01_fp_kind, 0.79658E-01_fp_kind,&
 0.78940E-01_fp_kind, 0.78197E-01_fp_kind, 0.77431E-01_fp_kind, 0.76644E-01_fp_kind, 0.75837E-01_fp_kind,&
 0.75011E-01_fp_kind, 0.74168E-01_fp_kind, 0.73309E-01_fp_kind, 0.74017E-01_fp_kind, 0.73105E-01_fp_kind,&
 0.72179E-01_fp_kind, 0.71243E-01_fp_kind, 0.70295E-01_fp_kind, 0.70833E-01_fp_kind, 0.69842E-01_fp_kind,&
 0.68843E-01_fp_kind, 0.67836E-01_fp_kind, 0.68255E-01_fp_kind, 0.67212E-01_fp_kind, 0.66162E-01_fp_kind,&
 0.66502E-01_fp_kind, 0.65421E-01_fp_kind, 0.64335E-01_fp_kind, 0.64601E-01_fp_kind, 0.63487E-01_fp_kind,&
 0.63708E-01_fp_kind, 0.62567E-01_fp_kind, 0.62746E-01_fp_kind, 0.61580E-01_fp_kind, 0.61717E-01_fp_kind,&
 0.60528E-01_fp_kind, 0.60625E-01_fp_kind, 0.59416E-01_fp_kind, 0.59474E-01_fp_kind, 0.58246E-01_fp_kind,&
 0.58267E-01_fp_kind, 0.57020E-01_fp_kind, 0.57006E-01_fp_kind, 0.56976E-01_fp_kind, 0.55694E-01_fp_kind,&
 0.55630E-01_fp_kind, 0.55550E-01_fp_kind, 0.54236E-01_fp_kind, 0.54124E-01_fp_kind, 0.53996E-01_fp_kind/

DATA (sdd(22,j),j=1,100) / &
 0.73496E-01_fp_kind, 0.79530E-01_fp_kind, 0.84585E-01_fp_kind, 0.90082E-01_fp_kind, 0.95138E-01_fp_kind,&
 0.97904E-01_fp_kind, 0.10030E+00_fp_kind, 0.10224E+00_fp_kind, 0.10493E+00_fp_kind, 0.10586E+00_fp_kind,&
 0.10641E+00_fp_kind, 0.10763E+00_fp_kind, 0.10750E+00_fp_kind, 0.10807E+00_fp_kind, 0.10839E+00_fp_kind,&
 0.10852E+00_fp_kind, 0.10853E+00_fp_kind, 0.10847E+00_fp_kind, 0.11051E+00_fp_kind, 0.11041E+00_fp_kind,&
 0.11003E+00_fp_kind, 0.10939E+00_fp_kind, 0.10852E+00_fp_kind, 0.10747E+00_fp_kind, 0.10951E+00_fp_kind,&
 0.10804E+00_fp_kind, 0.10645E+00_fp_kind, 0.10476E+00_fp_kind, 0.10597E+00_fp_kind, 0.10403E+00_fp_kind,&
 0.10204E+00_fp_kind, 0.10279E+00_fp_kind, 0.10064E+00_fp_kind, 0.10115E+00_fp_kind, 0.98878E-01_fp_kind,&
 0.99172E-01_fp_kind, 0.96826E-01_fp_kind, 0.96943E-01_fp_kind, 0.96973E-01_fp_kind, 0.94517E-01_fp_kind,&
 0.94411E-01_fp_kind, 0.94233E-01_fp_kind, 0.91723E-01_fp_kind, 0.91440E-01_fp_kind, 0.91100E-01_fp_kind,&
 0.90706E-01_fp_kind, 0.88155E-01_fp_kind, 0.87689E-01_fp_kind, 0.87178E-01_fp_kind, 0.86626E-01_fp_kind,&
 0.86035E-01_fp_kind, 0.85408E-01_fp_kind, 0.84747E-01_fp_kind, 0.84055E-01_fp_kind, 0.83333E-01_fp_kind,&
 0.82583E-01_fp_kind, 0.81808E-01_fp_kind, 0.81008E-01_fp_kind, 0.80186E-01_fp_kind, 0.79343E-01_fp_kind,&
 0.78481E-01_fp_kind, 0.77599E-01_fp_kind, 0.76701E-01_fp_kind, 0.75787E-01_fp_kind, 0.76488E-01_fp_kind,&
 0.75520E-01_fp_kind, 0.74540E-01_fp_kind, 0.73548E-01_fp_kind, 0.72545E-01_fp_kind, 0.73073E-01_fp_kind,&
 0.72026E-01_fp_kind, 0.70971E-01_fp_kind, 0.71409E-01_fp_kind, 0.70315E-01_fp_kind, 0.69214E-01_fp_kind,&
 0.69569E-01_fp_kind, 0.68434E-01_fp_kind, 0.67295E-01_fp_kind, 0.67571E-01_fp_kind, 0.66401E-01_fp_kind,&
 0.66630E-01_fp_kind, 0.65431E-01_fp_kind, 0.64231E-01_fp_kind, 0.64389E-01_fp_kind, 0.63163E-01_fp_kind,&
 0.63280E-01_fp_kind, 0.62030E-01_fp_kind, 0.62105E-01_fp_kind, 0.62162E-01_fp_kind, 0.60869E-01_fp_kind,&
 0.60886E-01_fp_kind, 0.59573E-01_fp_kind, 0.59553E-01_fp_kind, 0.59516E-01_fp_kind, 0.58166E-01_fp_kind,&
 0.58092E-01_fp_kind, 0.58002E-01_fp_kind, 0.56618E-01_fp_kind, 0.56493E-01_fp_kind, 0.56353E-01_fp_kind/

DATA (sdd(23,j),j=1,100) / &
 0.71097E-01_fp_kind, 0.80287E-01_fp_kind, 0.89572E-01_fp_kind, 0.93240E-01_fp_kind, 0.98978E-01_fp_kind,&
 0.10223E+00_fp_kind, 0.10353E+00_fp_kind, 0.10591E+00_fp_kind, 0.10775E+00_fp_kind, 0.10907E+00_fp_kind,&
 0.10996E+00_fp_kind, 0.11150E+00_fp_kind, 0.11165E+00_fp_kind, 0.11157E+00_fp_kind, 0.11219E+00_fp_kind,&
 0.11263E+00_fp_kind, 0.11214E+00_fp_kind, 0.11241E+00_fp_kind, 0.11529E+00_fp_kind, 0.11517E+00_fp_kind,&
 0.11475E+00_fp_kind, 0.11406E+00_fp_kind, 0.11315E+00_fp_kind, 0.11203E+00_fp_kind, 0.11073E+00_fp_kind,&
 0.11261E+00_fp_kind, 0.11094E+00_fp_kind, 0.10917E+00_fp_kind, 0.11042E+00_fp_kind, 0.10840E+00_fp_kind,&
 0.10632E+00_fp_kind, 0.10710E+00_fp_kind, 0.10486E+00_fp_kind, 0.10538E+00_fp_kind, 0.10302E+00_fp_kind,&
 0.10333E+00_fp_kind, 0.10089E+00_fp_kind, 0.10101E+00_fp_kind, 0.10105E+00_fp_kind, 0.98493E-01_fp_kind,&
 0.98386E-01_fp_kind, 0.98204E-01_fp_kind, 0.95594E-01_fp_kind, 0.95304E-01_fp_kind, 0.94955E-01_fp_kind,&
 0.94548E-01_fp_kind, 0.91896E-01_fp_kind, 0.91414E-01_fp_kind, 0.90887E-01_fp_kind, 0.90316E-01_fp_kind,&
 0.89705E-01_fp_kind, 0.89056E-01_fp_kind, 0.88371E-01_fp_kind, 0.87654E-01_fp_kind, 0.86905E-01_fp_kind,&
 0.86127E-01_fp_kind, 0.85322E-01_fp_kind, 0.84492E-01_fp_kind, 0.83638E-01_fp_kind, 0.82762E-01_fp_kind,&
 0.81865E-01_fp_kind, 0.80949E-01_fp_kind, 0.80014E-01_fp_kind, 0.79063E-01_fp_kind, 0.79795E-01_fp_kind,&
 0.78787E-01_fp_kind, 0.77765E-01_fp_kind, 0.76731E-01_fp_kind, 0.75685E-01_fp_kind, 0.76236E-01_fp_kind,&
 0.75144E-01_fp_kind, 0.74042E-01_fp_kind, 0.72932E-01_fp_kind, 0.73356E-01_fp_kind, 0.72206E-01_fp_kind,&
 0.71050E-01_fp_kind, 0.71388E-01_fp_kind, 0.70197E-01_fp_kind, 0.70483E-01_fp_kind, 0.69258E-01_fp_kind,&
 0.68030E-01_fp_kind, 0.68240E-01_fp_kind, 0.66983E-01_fp_kind, 0.67145E-01_fp_kind, 0.65860E-01_fp_kind,&
 0.65978E-01_fp_kind, 0.64668E-01_fp_kind, 0.64742E-01_fp_kind, 0.64796E-01_fp_kind, 0.63440E-01_fp_kind,&
 0.63453E-01_fp_kind, 0.62075E-01_fp_kind, 0.62048E-01_fp_kind, 0.62004E-01_fp_kind, 0.60585E-01_fp_kind,&
 0.60502E-01_fp_kind, 0.60402E-01_fp_kind, 0.58946E-01_fp_kind, 0.58809E-01_fp_kind, 0.58656E-01_fp_kind/

DATA (sdd(24,j),j=1,100) / &
 0.73682E-01_fp_kind, 0.84018E-01_fp_kind, 0.91212E-01_fp_kind, 0.98167E-01_fp_kind, 0.10237E+00_fp_kind,&
 0.10447E+00_fp_kind, 0.10785E+00_fp_kind, 0.11058E+00_fp_kind, 0.11143E+00_fp_kind, 0.11309E+00_fp_kind,&
 0.11427E+00_fp_kind, 0.11505E+00_fp_kind, 0.11550E+00_fp_kind, 0.11570E+00_fp_kind, 0.11573E+00_fp_kind,&
 0.11648E+00_fp_kind, 0.11631E+00_fp_kind, 0.11614E+00_fp_kind, 0.11970E+00_fp_kind, 0.11957E+00_fp_kind,&
 0.11912E+00_fp_kind, 0.11840E+00_fp_kind, 0.11745E+00_fp_kind, 0.11628E+00_fp_kind, 0.11494E+00_fp_kind,&
 0.11688E+00_fp_kind, 0.11515E+00_fp_kind, 0.11331E+00_fp_kind, 0.11462E+00_fp_kind, 0.11252E+00_fp_kind,&
 0.11037E+00_fp_kind, 0.11118E+00_fp_kind, 0.10886E+00_fp_kind, 0.10941E+00_fp_kind, 0.10697E+00_fp_kind,&
 0.10729E+00_fp_kind, 0.10477E+00_fp_kind, 0.10490E+00_fp_kind, 0.10494E+00_fp_kind, 0.10230E+00_fp_kind,&
 0.10220E+00_fp_kind, 0.10202E+00_fp_kind, 0.99318E-01_fp_kind, 0.99024E-01_fp_kind, 0.98669E-01_fp_kind,&
 0.98254E-01_fp_kind, 0.95509E-01_fp_kind, 0.95016E-01_fp_kind, 0.94475E-01_fp_kind, 0.93889E-01_fp_kind,&
 0.93261E-01_fp_kind, 0.92593E-01_fp_kind, 0.91888E-01_fp_kind, 0.91149E-01_fp_kind, 0.90376E-01_fp_kind,&
 0.89574E-01_fp_kind, 0.88743E-01_fp_kind, 0.87885E-01_fp_kind, 0.87002E-01_fp_kind, 0.86095E-01_fp_kind,&
 0.85167E-01_fp_kind, 0.84218E-01_fp_kind, 0.83249E-01_fp_kind, 0.82263E-01_fp_kind, 0.81259E-01_fp_kind,&
 0.81980E-01_fp_kind, 0.80919E-01_fp_kind, 0.79845E-01_fp_kind, 0.78758E-01_fp_kind, 0.79331E-01_fp_kind,&
 0.78195E-01_fp_kind, 0.77049E-01_fp_kind, 0.75894E-01_fp_kind, 0.76334E-01_fp_kind, 0.75137E-01_fp_kind,&
 0.73932E-01_fp_kind, 0.74282E-01_fp_kind, 0.73040E-01_fp_kind, 0.73336E-01_fp_kind, 0.72059E-01_fp_kind,&
 0.70777E-01_fp_kind, 0.70992E-01_fp_kind, 0.69679E-01_fp_kind, 0.69845E-01_fp_kind, 0.68502E-01_fp_kind,&
 0.68621E-01_fp_kind, 0.67250E-01_fp_kind, 0.67323E-01_fp_kind, 0.67376E-01_fp_kind, 0.65956E-01_fp_kind,&
 0.65965E-01_fp_kind, 0.64522E-01_fp_kind, 0.64488E-01_fp_kind, 0.64436E-01_fp_kind, 0.62950E-01_fp_kind,&
 0.62857E-01_fp_kind, 0.62746E-01_fp_kind, 0.61219E-01_fp_kind, 0.61069E-01_fp_kind, 0.60902E-01_fp_kind/

DATA (sdd(25,j),j=1,100) / &
 0.81821E-01_fp_kind, 0.87202E-01_fp_kind, 0.95201E-01_fp_kind, 0.10040E+00_fp_kind, 0.10537E+00_fp_kind,&
 0.10802E+00_fp_kind, 0.11186E+00_fp_kind, 0.11355E+00_fp_kind, 0.11610E+00_fp_kind, 0.11682E+00_fp_kind,&
 0.11831E+00_fp_kind, 0.11831E+00_fp_kind, 0.11908E+00_fp_kind, 0.11959E+00_fp_kind, 0.11991E+00_fp_kind,&
 0.12011E+00_fp_kind, 0.12027E+00_fp_kind, 0.12352E+00_fp_kind, 0.12375E+00_fp_kind, 0.12362E+00_fp_kind,&
 0.12317E+00_fp_kind, 0.12243E+00_fp_kind, 0.12144E+00_fp_kind, 0.12025E+00_fp_kind, 0.12253E+00_fp_kind,&
 0.12088E+00_fp_kind, 0.11910E+00_fp_kind, 0.11721E+00_fp_kind, 0.11857E+00_fp_kind, 0.11641E+00_fp_kind,&
 0.11419E+00_fp_kind, 0.11504E+00_fp_kind, 0.11266E+00_fp_kind, 0.11323E+00_fp_kind, 0.11072E+00_fp_kind,&
 0.11107E+00_fp_kind, 0.10847E+00_fp_kind, 0.10862E+00_fp_kind, 0.10867E+00_fp_kind, 0.10595E+00_fp_kind,&
 0.10586E+00_fp_kind, 0.10568E+00_fp_kind, 0.10290E+00_fp_kind, 0.10261E+00_fp_kind, 0.10225E+00_fp_kind,&
 0.10183E+00_fp_kind, 0.99000E-01_fp_kind, 0.98499E-01_fp_kind, 0.97948E-01_fp_kind, 0.97350E-01_fp_kind,&
 0.96708E-01_fp_kind, 0.96024E-01_fp_kind, 0.95302E-01_fp_kind, 0.94544E-01_fp_kind, 0.93751E-01_fp_kind,&
 0.92926E-01_fp_kind, 0.92072E-01_fp_kind, 0.91189E-01_fp_kind, 0.90279E-01_fp_kind, 0.89345E-01_fp_kind,&
 0.88387E-01_fp_kind, 0.87407E-01_fp_kind, 0.86407E-01_fp_kind, 0.85388E-01_fp_kind, 0.84350E-01_fp_kind,&
 0.85100E-01_fp_kind, 0.84002E-01_fp_kind, 0.82889E-01_fp_kind, 0.81763E-01_fp_kind, 0.82359E-01_fp_kind,&
 0.81181E-01_fp_kind, 0.79992E-01_fp_kind, 0.78793E-01_fp_kind, 0.79250E-01_fp_kind, 0.78006E-01_fp_kind,&
 0.76753E-01_fp_kind, 0.77116E-01_fp_kind, 0.75824E-01_fp_kind, 0.76130E-01_fp_kind, 0.74800E-01_fp_kind,&
 0.73465E-01_fp_kind, 0.73687E-01_fp_kind, 0.72318E-01_fp_kind, 0.72487E-01_fp_kind, 0.71087E-01_fp_kind,&
 0.71207E-01_fp_kind, 0.69777E-01_fp_kind, 0.69848E-01_fp_kind, 0.69899E-01_fp_kind, 0.68416E-01_fp_kind,&
 0.68420E-01_fp_kind, 0.66912E-01_fp_kind, 0.66872E-01_fp_kind, 0.66811E-01_fp_kind, 0.65257E-01_fp_kind,&
 0.65154E-01_fp_kind, 0.65031E-01_fp_kind, 0.63434E-01_fp_kind, 0.63271E-01_fp_kind, 0.63089E-01_fp_kind/

DATA (sdd(26,j),j=1,100) / &
 0.82802E-01_fp_kind, 0.89906E-01_fp_kind, 0.98825E-01_fp_kind, 0.10226E+00_fp_kind, 0.10803E+00_fp_kind,&
 0.11126E+00_fp_kind, 0.11558E+00_fp_kind, 0.11765E+00_fp_kind, 0.11920E+00_fp_kind, 0.12028E+00_fp_kind,&
 0.12211E+00_fp_kind, 0.12239E+00_fp_kind, 0.12344E+00_fp_kind, 0.12325E+00_fp_kind, 0.12389E+00_fp_kind,&
 0.12441E+00_fp_kind, 0.12407E+00_fp_kind, 0.12722E+00_fp_kind, 0.12747E+00_fp_kind, 0.12735E+00_fp_kind,&
 0.12690E+00_fp_kind, 0.12615E+00_fp_kind, 0.12515E+00_fp_kind, 0.12393E+00_fp_kind, 0.12630E+00_fp_kind,&
 0.12461E+00_fp_kind, 0.12280E+00_fp_kind, 0.12087E+00_fp_kind, 0.12228E+00_fp_kind, 0.12007E+00_fp_kind,&
 0.11781E+00_fp_kind, 0.11870E+00_fp_kind, 0.11626E+00_fp_kind, 0.11687E+00_fp_kind, 0.11429E+00_fp_kind,&
 0.11466E+00_fp_kind, 0.11200E+00_fp_kind, 0.11217E+00_fp_kind, 0.11224E+00_fp_kind, 0.10945E+00_fp_kind,&
 0.10937E+00_fp_kind, 0.10920E+00_fp_kind, 0.10635E+00_fp_kind, 0.10606E+00_fp_kind, 0.10570E+00_fp_kind,&
 0.10528E+00_fp_kind, 0.10237E+00_fp_kind, 0.10187E+00_fp_kind, 0.10131E+00_fp_kind, 0.10070E+00_fp_kind,&
 0.10005E+00_fp_kind, 0.99353E-01_fp_kind, 0.98616E-01_fp_kind, 0.97841E-01_fp_kind, 0.97031E-01_fp_kind,&
 0.96187E-01_fp_kind, 0.95311E-01_fp_kind, 0.94405E-01_fp_kind, 0.93471E-01_fp_kind, 0.92511E-01_fp_kind,&
 0.91527E-01_fp_kind, 0.90519E-01_fp_kind, 0.89489E-01_fp_kind, 0.88438E-01_fp_kind, 0.87368E-01_fp_kind,&
 0.88147E-01_fp_kind, 0.87014E-01_fp_kind, 0.85865E-01_fp_kind, 0.84701E-01_fp_kind, 0.83523E-01_fp_kind,&
 0.84101E-01_fp_kind, 0.82870E-01_fp_kind, 0.81628E-01_fp_kind, 0.82101E-01_fp_kind, 0.80812E-01_fp_kind,&
 0.79513E-01_fp_kind, 0.79888E-01_fp_kind, 0.78547E-01_fp_kind, 0.78863E-01_fp_kind, 0.77482E-01_fp_kind,&
 0.76095E-01_fp_kind, 0.76321E-01_fp_kind, 0.74898E-01_fp_kind, 0.75071E-01_fp_kind, 0.73614E-01_fp_kind,&
 0.73734E-01_fp_kind, 0.72245E-01_fp_kind, 0.72315E-01_fp_kind, 0.72362E-01_fp_kind, 0.70817E-01_fp_kind,&
 0.70816E-01_fp_kind, 0.69243E-01_fp_kind, 0.69195E-01_fp_kind, 0.69126E-01_fp_kind, 0.67504E-01_fp_kind,&
 0.67390E-01_fp_kind, 0.67256E-01_fp_kind, 0.65588E-01_fp_kind, 0.65410E-01_fp_kind, 0.65213E-01_fp_kind/

DATA (sdd(27,j),j=1,100) / &
 0.83173E-01_fp_kind, 0.92191E-01_fp_kind, 0.99140E-01_fp_kind, 0.10614E+00_fp_kind, 0.11039E+00_fp_kind,&
 0.11600E+00_fp_kind, 0.11746E+00_fp_kind, 0.12005E+00_fp_kind, 0.12205E+00_fp_kind, 0.12351E+00_fp_kind,&
 0.12568E+00_fp_kind, 0.12626E+00_fp_kind, 0.12658E+00_fp_kind, 0.12673E+00_fp_kind, 0.12769E+00_fp_kind,&
 0.12768E+00_fp_kind, 0.12852E+00_fp_kind, 0.13058E+00_fp_kind, 0.13087E+00_fp_kind, 0.13077E+00_fp_kind,&
 0.13033E+00_fp_kind, 0.12959E+00_fp_kind, 0.12859E+00_fp_kind, 0.13134E+00_fp_kind, 0.12980E+00_fp_kind,&
 0.12810E+00_fp_kind, 0.12626E+00_fp_kind, 0.12794E+00_fp_kind, 0.12577E+00_fp_kind, 0.12352E+00_fp_kind,&
 0.12462E+00_fp_kind, 0.12216E+00_fp_kind, 0.11967E+00_fp_kind, 0.12031E+00_fp_kind, 0.11769E+00_fp_kind,&
 0.11809E+00_fp_kind, 0.11837E+00_fp_kind, 0.11557E+00_fp_kind, 0.11566E+00_fp_kind, 0.11281E+00_fp_kind,&
 0.11274E+00_fp_kind, 0.11258E+00_fp_kind, 0.10966E+00_fp_kind, 0.10938E+00_fp_kind, 0.10903E+00_fp_kind,&
 0.10861E+00_fp_kind, 0.10813E+00_fp_kind, 0.10512E+00_fp_kind, 0.10456E+00_fp_kind, 0.10395E+00_fp_kind,&
 0.10329E+00_fp_kind, 0.10258E+00_fp_kind, 0.10183E+00_fp_kind, 0.10104E+00_fp_kind, 0.10022E+00_fp_kind,&
 0.99357E-01_fp_kind, 0.98462E-01_fp_kind, 0.97536E-01_fp_kind, 0.96580E-01_fp_kind, 0.95597E-01_fp_kind,&
 0.94587E-01_fp_kind, 0.93552E-01_fp_kind, 0.92495E-01_fp_kind, 0.91415E-01_fp_kind, 0.90314E-01_fp_kind,&
 0.91121E-01_fp_kind, 0.89955E-01_fp_kind, 0.88770E-01_fp_kind, 0.87570E-01_fp_kind, 0.86355E-01_fp_kind,&
 0.86953E-01_fp_kind, 0.85682E-01_fp_kind, 0.84399E-01_fp_kind, 0.84888E-01_fp_kind, 0.83555E-01_fp_kind,&
 0.82211E-01_fp_kind, 0.82598E-01_fp_kind, 0.81209E-01_fp_kind, 0.81533E-01_fp_kind, 0.80102E-01_fp_kind,&
 0.78663E-01_fp_kind, 0.78895E-01_fp_kind, 0.77418E-01_fp_kind, 0.77593E-01_fp_kind, 0.76080E-01_fp_kind,&
 0.76200E-01_fp_kind, 0.74653E-01_fp_kind, 0.74720E-01_fp_kind, 0.74764E-01_fp_kind, 0.73157E-01_fp_kind,&
 0.73150E-01_fp_kind, 0.71513E-01_fp_kind, 0.71457E-01_fp_kind, 0.71378E-01_fp_kind, 0.69689E-01_fp_kind,&
 0.69563E-01_fp_kind, 0.69416E-01_fp_kind, 0.69248E-01_fp_kind, 0.67485E-01_fp_kind, 0.67272E-01_fp_kind/

DATA (sdd(28,j),j=1,100) / &
 0.83070E-01_fp_kind, 0.94113E-01_fp_kind, 0.10209E+00_fp_kind, 0.10979E+00_fp_kind, 0.11452E+00_fp_kind,&
 0.11874E+00_fp_kind, 0.12229E+00_fp_kind, 0.12367E+00_fp_kind, 0.12601E+00_fp_kind, 0.12777E+00_fp_kind,&
 0.12905E+00_fp_kind, 0.12995E+00_fp_kind, 0.13056E+00_fp_kind, 0.13100E+00_fp_kind, 0.13134E+00_fp_kind,&
 0.13166E+00_fp_kind, 0.13368E+00_fp_kind, 0.13837E+00_fp_kind, 0.13397E+00_fp_kind, 0.13391E+00_fp_kind,&
 0.13349E+00_fp_kind, 0.13707E+00_fp_kind, 0.13596E+00_fp_kind, 0.13461E+00_fp_kind, 0.13307E+00_fp_kind,&
 0.13135E+00_fp_kind, 0.12950E+00_fp_kind, 0.13124E+00_fp_kind, 0.12905E+00_fp_kind, 0.12678E+00_fp_kind,&
 0.12792E+00_fp_kind, 0.12543E+00_fp_kind, 0.12625E+00_fp_kind, 0.12359E+00_fp_kind, 0.12413E+00_fp_kind,&
 0.12136E+00_fp_kind, 0.12167E+00_fp_kind, 0.11881E+00_fp_kind, 0.11893E+00_fp_kind, 0.11603E+00_fp_kind,&
 0.11597E+00_fp_kind, 0.11583E+00_fp_kind, 0.11560E+00_fp_kind, 0.11258E+00_fp_kind, 0.11223E+00_fp_kind,&
 0.11182E+00_fp_kind, 0.11134E+00_fp_kind, 0.10827E+00_fp_kind, 0.10771E+00_fp_kind, 0.10709E+00_fp_kind,&
 0.10643E+00_fp_kind, 0.10571E+00_fp_kind, 0.10495E+00_fp_kind, 0.10415E+00_fp_kind, 0.10331E+00_fp_kind,&
 0.10244E+00_fp_kind, 0.10153E+00_fp_kind, 0.10058E+00_fp_kind, 0.99607E-01_fp_kind, 0.98602E-01_fp_kind,&
 0.97569E-01_fp_kind, 0.96510E-01_fp_kind, 0.95426E-01_fp_kind, 0.94318E-01_fp_kind, 0.93189E-01_fp_kind,&
 0.94024E-01_fp_kind, 0.92825E-01_fp_kind, 0.91607E-01_fp_kind, 0.90372E-01_fp_kind, 0.91035E-01_fp_kind,&
 0.89739E-01_fp_kind, 0.88429E-01_fp_kind, 0.87105E-01_fp_kind, 0.87610E-01_fp_kind, 0.86233E-01_fp_kind,&
 0.84845E-01_fp_kind, 0.85244E-01_fp_kind, 0.83807E-01_fp_kind, 0.84141E-01_fp_kind, 0.82660E-01_fp_kind,&
 0.81170E-01_fp_kind, 0.81407E-01_fp_kind, 0.79877E-01_fp_kind, 0.80054E-01_fp_kind, 0.78485E-01_fp_kind,&
 0.78604E-01_fp_kind, 0.76999E-01_fp_kind, 0.77063E-01_fp_kind, 0.77103E-01_fp_kind, 0.75434E-01_fp_kind,&
 0.75420E-01_fp_kind, 0.73720E-01_fp_kind, 0.73655E-01_fp_kind, 0.73566E-01_fp_kind, 0.71809E-01_fp_kind,&
 0.71671E-01_fp_kind, 0.71511E-01_fp_kind, 0.71328E-01_fp_kind, 0.69493E-01_fp_kind, 0.69263E-01_fp_kind/

DATA (sdd(29,j),j=1,100) / &
 0.89117E-01_fp_kind, 0.99844E-01_fp_kind, 0.10478E+00_fp_kind, 0.11321E+00_fp_kind, 0.11637E+00_fp_kind,&
 0.12124E+00_fp_kind, 0.12531E+00_fp_kind, 0.12710E+00_fp_kind, 0.12979E+00_fp_kind, 0.13058E+00_fp_kind,&
 0.13222E+00_fp_kind, 0.13346E+00_fp_kind, 0.13334E+00_fp_kind, 0.13414E+00_fp_kind, 0.13484E+00_fp_kind,&
 0.13551E+00_fp_kind, 0.14046E+00_fp_kind, 0.14122E+00_fp_kind, 0.14151E+00_fp_kind, 0.14138E+00_fp_kind,&
 0.14088E+00_fp_kind, 0.14007E+00_fp_kind, 0.13898E+00_fp_kind, 0.13764E+00_fp_kind, 0.13610E+00_fp_kind,&
 0.13438E+00_fp_kind, 0.13645E+00_fp_kind, 0.13434E+00_fp_kind, 0.13213E+00_fp_kind, 0.13351E+00_fp_kind,&
 0.13104E+00_fp_kind, 0.12852E+00_fp_kind, 0.12938E+00_fp_kind, 0.12669E+00_fp_kind, 0.12728E+00_fp_kind,&
 0.12447E+00_fp_kind, 0.12481E+00_fp_kind, 0.12191E+00_fp_kind, 0.12205E+00_fp_kind, 0.12209E+00_fp_kind,&
 0.11907E+00_fp_kind, 0.11895E+00_fp_kind, 0.11874E+00_fp_kind, 0.11566E+00_fp_kind, 0.11533E+00_fp_kind,&
 0.11492E+00_fp_kind, 0.11445E+00_fp_kind, 0.11391E+00_fp_kind, 0.11075E+00_fp_kind, 0.11014E+00_fp_kind,&
 0.10947E+00_fp_kind, 0.10875E+00_fp_kind, 0.10798E+00_fp_kind, 0.10717E+00_fp_kind, 0.10632E+00_fp_kind,&
 0.10543E+00_fp_kind, 0.10451E+00_fp_kind, 0.10355E+00_fp_kind, 0.10255E+00_fp_kind, 0.10153E+00_fp_kind,&
 0.10047E+00_fp_kind, 0.99392E-01_fp_kind, 0.98283E-01_fp_kind, 0.97149E-01_fp_kind, 0.98065E-01_fp_kind,&
 0.96855E-01_fp_kind, 0.95625E-01_fp_kind, 0.94375E-01_fp_kind, 0.93106E-01_fp_kind, 0.93790E-01_fp_kind,&
 0.92458E-01_fp_kind, 0.91109E-01_fp_kind, 0.89746E-01_fp_kind, 0.90266E-01_fp_kind, 0.88847E-01_fp_kind,&
 0.87415E-01_fp_kind, 0.87825E-01_fp_kind, 0.86342E-01_fp_kind, 0.86684E-01_fp_kind, 0.85154E-01_fp_kind,&
 0.83614E-01_fp_kind, 0.83855E-01_fp_kind, 0.82272E-01_fp_kind, 0.82450E-01_fp_kind, 0.80826E-01_fp_kind,&
 0.80945E-01_fp_kind, 0.81037E-01_fp_kind, 0.79342E-01_fp_kind, 0.79377E-01_fp_kind, 0.77646E-01_fp_kind,&
 0.77626E-01_fp_kind, 0.77580E-01_fp_kind, 0.75786E-01_fp_kind, 0.75687E-01_fp_kind, 0.75564E-01_fp_kind,&
 0.73711E-01_fp_kind, 0.73537E-01_fp_kind, 0.73339E-01_fp_kind, 0.71431E-01_fp_kind, 0.71184E-01_fp_kind/

DATA (sdd(30,j),j=1,100) / &
 0.88106E-01_fp_kind, 0.10116E+00_fp_kind, 0.10723E+00_fp_kind, 0.11394E+00_fp_kind, 0.12009E+00_fp_kind,&
 0.12539E+00_fp_kind, 0.12814E+00_fp_kind, 0.13034E+00_fp_kind, 0.13341E+00_fp_kind, 0.13450E+00_fp_kind,&
 0.13522E+00_fp_kind, 0.13680E+00_fp_kind, 0.13700E+00_fp_kind, 0.13813E+00_fp_kind, 0.13820E+00_fp_kind,&
 0.13925E+00_fp_kind, 0.14295E+00_fp_kind, 0.14378E+00_fp_kind, 0.14413E+00_fp_kind, 0.14405E+00_fp_kind,&
 0.14360E+00_fp_kind, 0.14282E+00_fp_kind, 0.14175E+00_fp_kind, 0.14044E+00_fp_kind, 0.13891E+00_fp_kind,&
 0.14133E+00_fp_kind, 0.13934E+00_fp_kind, 0.13723E+00_fp_kind, 0.13502E+00_fp_kind, 0.13646E+00_fp_kind,&
 0.13398E+00_fp_kind, 0.13505E+00_fp_kind, 0.13235E+00_fp_kind, 0.12964E+00_fp_kind, 0.13027E+00_fp_kind,&
 0.12743E+00_fp_kind, 0.12781E+00_fp_kind, 0.12806E+00_fp_kind, 0.12505E+00_fp_kind, 0.12511E+00_fp_kind,&
 0.12205E+00_fp_kind, 0.12195E+00_fp_kind, 0.12175E+00_fp_kind, 0.12148E+00_fp_kind, 0.11831E+00_fp_kind,&
 0.11791E+00_fp_kind, 0.11745E+00_fp_kind, 0.11692E+00_fp_kind, 0.11633E+00_fp_kind, 0.11309E+00_fp_kind,&
 0.11241E+00_fp_kind, 0.11169E+00_fp_kind, 0.11092E+00_fp_kind, 0.11011E+00_fp_kind, 0.10925E+00_fp_kind,&
 0.10835E+00_fp_kind, 0.10741E+00_fp_kind, 0.10643E+00_fp_kind, 0.10542E+00_fp_kind, 0.10438E+00_fp_kind,&
 0.10330E+00_fp_kind, 0.10220E+00_fp_kind, 0.10107E+00_fp_kind, 0.99908E-01_fp_kind, 0.10085E+00_fp_kind,&
 0.99615E-01_fp_kind, 0.98355E-01_fp_kind, 0.97074E-01_fp_kind, 0.95772E-01_fp_kind, 0.96477E-01_fp_kind,&
 0.95109E-01_fp_kind, 0.93723E-01_fp_kind, 0.92321E-01_fp_kind, 0.92856E-01_fp_kind, 0.91396E-01_fp_kind,&
 0.89921E-01_fp_kind, 0.90341E-01_fp_kind, 0.88812E-01_fp_kind, 0.89162E-01_fp_kind, 0.87583E-01_fp_kind,&
 0.87865E-01_fp_kind, 0.86238E-01_fp_kind, 0.84603E-01_fp_kind, 0.84782E-01_fp_kind, 0.83103E-01_fp_kind,&
 0.83220E-01_fp_kind, 0.83309E-01_fp_kind, 0.81555E-01_fp_kind, 0.81585E-01_fp_kind, 0.79793E-01_fp_kind,&
 0.79764E-01_fp_kind, 0.79710E-01_fp_kind, 0.77850E-01_fp_kind, 0.77740E-01_fp_kind, 0.77604E-01_fp_kind,&
 0.75682E-01_fp_kind, 0.75493E-01_fp_kind, 0.75279E-01_fp_kind, 0.75041E-01_fp_kind, 0.73033E-01_fp_kind/

DATA (sdd(31,j),j=1,100) / &
 0.93581E-01_fp_kind, 0.10222E+00_fp_kind, 0.11260E+00_fp_kind, 0.11694E+00_fp_kind, 0.12365E+00_fp_kind,&
 0.12751E+00_fp_kind, 0.13078E+00_fp_kind, 0.13341E+00_fp_kind, 0.13544E+00_fp_kind, 0.13827E+00_fp_kind,&
 0.13928E+00_fp_kind, 0.14000E+00_fp_kind, 0.14054E+00_fp_kind, 0.14200E+00_fp_kind, 0.14239E+00_fp_kind,&
 0.14289E+00_fp_kind, 0.15041E+00_fp_kind, 0.14607E+00_fp_kind, 0.14649E+00_fp_kind, 0.14648E+00_fp_kind,&
 0.14608E+00_fp_kind, 0.14534E+00_fp_kind, 0.14430E+00_fp_kind, 0.14746E+00_fp_kind, 0.14583E+00_fp_kind,&
 0.14401E+00_fp_kind, 0.14204E+00_fp_kind, 0.13994E+00_fp_kind, 0.14166E+00_fp_kind, 0.13923E+00_fp_kind,&
 0.13674E+00_fp_kind, 0.13787E+00_fp_kind, 0.13517E+00_fp_kind, 0.13597E+00_fp_kind, 0.13311E+00_fp_kind,&
 0.13363E+00_fp_kind, 0.13066E+00_fp_kind, 0.13095E+00_fp_kind, 0.12791E+00_fp_kind, 0.12800E+00_fp_kind,&
 0.12798E+00_fp_kind, 0.12483E+00_fp_kind, 0.12465E+00_fp_kind, 0.12440E+00_fp_kind, 0.12118E+00_fp_kind,&
 0.12080E+00_fp_kind, 0.12034E+00_fp_kind, 0.11982E+00_fp_kind, 0.11924E+00_fp_kind, 0.11594E+00_fp_kind,&
 0.11527E+00_fp_kind, 0.11455E+00_fp_kind, 0.11377E+00_fp_kind, 0.11295E+00_fp_kind, 0.11208E+00_fp_kind,&
 0.11117E+00_fp_kind, 0.11022E+00_fp_kind, 0.10923E+00_fp_kind, 0.10821E+00_fp_kind, 0.10715E+00_fp_kind,&
 0.10605E+00_fp_kind, 0.10493E+00_fp_kind, 0.10378E+00_fp_kind, 0.10481E+00_fp_kind, 0.10357E+00_fp_kind,&
 0.10230E+00_fp_kind, 0.10101E+00_fp_kind, 0.99703E-01_fp_kind, 0.98369E-01_fp_kind, 0.99095E-01_fp_kind,&
 0.97692E-01_fp_kind, 0.96270E-01_fp_kind, 0.96865E-01_fp_kind, 0.95379E-01_fp_kind, 0.93878E-01_fp_kind,&
 0.94350E-01_fp_kind, 0.92790E-01_fp_kind, 0.91217E-01_fp_kind, 0.91573E-01_fp_kind, 0.89946E-01_fp_kind,&
 0.90232E-01_fp_kind, 0.88555E-01_fp_kind, 0.88772E-01_fp_kind, 0.87047E-01_fp_kind, 0.87198E-01_fp_kind,&
 0.85427E-01_fp_kind, 0.85514E-01_fp_kind, 0.83700E-01_fp_kind, 0.83724E-01_fp_kind, 0.81870E-01_fp_kind,&
 0.81833E-01_fp_kind, 0.81769E-01_fp_kind, 0.79844E-01_fp_kind, 0.79721E-01_fp_kind, 0.79573E-01_fp_kind,&
 0.77581E-01_fp_kind, 0.77376E-01_fp_kind, 0.77145E-01_fp_kind, 0.76890E-01_fp_kind, 0.74807E-01_fp_kind/

DATA (sdd(32,j),j=1,100) / &
 0.93550E-01_fp_kind, 0.10471E+00_fp_kind, 0.11322E+00_fp_kind, 0.12153E+00_fp_kind, 0.12671E+00_fp_kind,&
 0.13131E+00_fp_kind, 0.13518E+00_fp_kind, 0.13830E+00_fp_kind, 0.14076E+00_fp_kind, 0.14131E+00_fp_kind,&
 0.14285E+00_fp_kind, 0.14406E+00_fp_kind, 0.14506E+00_fp_kind, 0.14596E+00_fp_kind, 0.14688E+00_fp_kind,&
 0.14878E+00_fp_kind, 0.15485E+00_fp_kind, 0.15575E+00_fp_kind, 0.15095E+00_fp_kind, 0.15099E+00_fp_kind,&
 0.15063E+00_fp_kind, 0.14992E+00_fp_kind, 0.14891E+00_fp_kind, 0.15220E+00_fp_kind, 0.15056E+00_fp_kind,&
 0.14874E+00_fp_kind, 0.14675E+00_fp_kind, 0.14463E+00_fp_kind, 0.14645E+00_fp_kind, 0.14399E+00_fp_kind,&
 0.14146E+00_fp_kind, 0.14266E+00_fp_kind, 0.13991E+00_fp_kind, 0.14077E+00_fp_kind, 0.13786E+00_fp_kind,&
 0.13843E+00_fp_kind, 0.13540E+00_fp_kind, 0.13573E+00_fp_kind, 0.13262E+00_fp_kind, 0.13274E+00_fp_kind,&
 0.13275E+00_fp_kind, 0.12952E+00_fp_kind, 0.12937E+00_fp_kind, 0.12913E+00_fp_kind, 0.12583E+00_fp_kind,&
 0.12545E+00_fp_kind, 0.12500E+00_fp_kind, 0.12448E+00_fp_kind, 0.12390E+00_fp_kind, 0.12050E+00_fp_kind,&
 0.11983E+00_fp_kind, 0.11909E+00_fp_kind, 0.11831E+00_fp_kind, 0.11747E+00_fp_kind, 0.11658E+00_fp_kind,&
 0.11565E+00_fp_kind, 0.11468E+00_fp_kind, 0.11366E+00_fp_kind, 0.11261E+00_fp_kind, 0.11152E+00_fp_kind,&
 0.11039E+00_fp_kind, 0.10923E+00_fp_kind, 0.10804E+00_fp_kind, 0.10682E+00_fp_kind, 0.10557E+00_fp_kind,&
 0.10653E+00_fp_kind, 0.10519E+00_fp_kind, 0.10383E+00_fp_kind, 0.10245E+00_fp_kind, 0.10104E+00_fp_kind,&
 0.10175E+00_fp_kind, 0.10027E+00_fp_kind, 0.98767E-01_fp_kind, 0.99340E-01_fp_kind, 0.97774E-01_fp_kind,&
 0.96192E-01_fp_kind, 0.96638E-01_fp_kind, 0.94995E-01_fp_kind, 0.93338E-01_fp_kind, 0.93664E-01_fp_kind,&
 0.91950E-01_fp_kind, 0.92203E-01_fp_kind, 0.90437E-01_fp_kind, 0.90619E-01_fp_kind, 0.88802E-01_fp_kind,&
 0.88915E-01_fp_kind, 0.87051E-01_fp_kind, 0.87097E-01_fp_kind, 0.87114E-01_fp_kind, 0.85168E-01_fp_kind,&
 0.85121E-01_fp_kind, 0.85045E-01_fp_kind, 0.83022E-01_fp_kind, 0.82884E-01_fp_kind, 0.82718E-01_fp_kind,&
 0.80624E-01_fp_kind, 0.80398E-01_fp_kind, 0.80145E-01_fp_kind, 0.79866E-01_fp_kind, 0.77673E-01_fp_kind/

DATA (sdd(33,j),j=1,100) / &
 0.98513E-01_fp_kind, 0.10959E+00_fp_kind, 0.11824E+00_fp_kind, 0.12417E+00_fp_kind, 0.12991E+00_fp_kind,&
 0.13496E+00_fp_kind, 0.13745E+00_fp_kind, 0.14103E+00_fp_kind, 0.14387E+00_fp_kind, 0.14476E+00_fp_kind,&
 0.14661E+00_fp_kind, 0.14812E+00_fp_kind, 0.14832E+00_fp_kind, 0.14958E+00_fp_kind, 0.15085E+00_fp_kind,&
 0.15495E+00_fp_kind, 0.15654E+00_fp_kind, 0.15754E+00_fp_kind, 0.15801E+00_fp_kind, 0.15801E+00_fp_kind,&
 0.15760E+00_fp_kind, 0.15682E+00_fp_kind, 0.15574E+00_fp_kind, 0.15438E+00_fp_kind, 0.15279E+00_fp_kind,&
 0.15100E+00_fp_kind, 0.15341E+00_fp_kind, 0.15118E+00_fp_kind, 0.14884E+00_fp_kind, 0.14640E+00_fp_kind,&
 0.14784E+00_fp_kind, 0.14514E+00_fp_kind, 0.14621E+00_fp_kind, 0.14331E+00_fp_kind, 0.14040E+00_fp_kind,&
 0.14102E+00_fp_kind, 0.14150E+00_fp_kind, 0.13835E+00_fp_kind, 0.13859E+00_fp_kind, 0.13537E+00_fp_kind,&
 0.13542E+00_fp_kind, 0.13536E+00_fp_kind, 0.13203E+00_fp_kind, 0.13181E+00_fp_kind, 0.13150E+00_fp_kind,&
 0.12812E+00_fp_kind, 0.12769E+00_fp_kind, 0.12718E+00_fp_kind, 0.12660E+00_fp_kind, 0.12596E+00_fp_kind,&
 0.12249E+00_fp_kind, 0.12176E+00_fp_kind, 0.12097E+00_fp_kind, 0.12014E+00_fp_kind, 0.11925E+00_fp_kind,&
 0.11831E+00_fp_kind, 0.11733E+00_fp_kind, 0.11630E+00_fp_kind, 0.11524E+00_fp_kind, 0.11413E+00_fp_kind,&
 0.11299E+00_fp_kind, 0.11181E+00_fp_kind, 0.11060E+00_fp_kind, 0.10936E+00_fp_kind, 0.11040E+00_fp_kind,&
 0.10907E+00_fp_kind, 0.10771E+00_fp_kind, 0.10632E+00_fp_kind, 0.10490E+00_fp_kind, 0.10568E+00_fp_kind,&
 0.10419E+00_fp_kind, 0.10267E+00_fp_kind, 0.10114E+00_fp_kind, 0.10172E+00_fp_kind, 0.10012E+00_fp_kind,&
 0.98493E-01_fp_kind, 0.98947E-01_fp_kind, 0.97260E-01_fp_kind, 0.97635E-01_fp_kind, 0.95887E-01_fp_kind,&
 0.94125E-01_fp_kind, 0.94379E-01_fp_kind, 0.92561E-01_fp_kind, 0.92742E-01_fp_kind, 0.90870E-01_fp_kind,&
 0.90979E-01_fp_kind, 0.91057E-01_fp_kind, 0.89097E-01_fp_kind, 0.89106E-01_fp_kind, 0.87098E-01_fp_kind,&
 0.87040E-01_fp_kind, 0.86952E-01_fp_kind, 0.84864E-01_fp_kind, 0.84712E-01_fp_kind, 0.84531E-01_fp_kind,&
 0.82366E-01_fp_kind, 0.82123E-01_fp_kind, 0.81851E-01_fp_kind, 0.81551E-01_fp_kind, 0.81223E-01_fp_kind/

DATA (sdd(34,j),j=1,100) / &
 0.96196E-01_fp_kind, 0.10996E+00_fp_kind, 0.11992E+00_fp_kind, 0.12666E+00_fp_kind, 0.13299E+00_fp_kind,&
 0.13653E+00_fp_kind, 0.14132E+00_fp_kind, 0.14362E+00_fp_kind, 0.14686E+00_fp_kind, 0.14809E+00_fp_kind,&
 0.15027E+00_fp_kind, 0.15090E+00_fp_kind, 0.15257E+00_fp_kind, 0.15310E+00_fp_kind, 0.15378E+00_fp_kind,&
 0.16206E+00_fp_kind, 0.15800E+00_fp_kind, 0.15910E+00_fp_kind, 0.15966E+00_fp_kind, 0.15975E+00_fp_kind,&
 0.15941E+00_fp_kind, 0.15871E+00_fp_kind, 0.15768E+00_fp_kind, 0.15638E+00_fp_kind, 0.15484E+00_fp_kind,&
 0.15764E+00_fp_kind, 0.15558E+00_fp_kind, 0.15339E+00_fp_kind, 0.15107E+00_fp_kind, 0.15279E+00_fp_kind,&
 0.15017E+00_fp_kind, 0.14748E+00_fp_kind, 0.14861E+00_fp_kind, 0.14572E+00_fp_kind, 0.14652E+00_fp_kind,&
 0.14347E+00_fp_kind, 0.14400E+00_fp_kind, 0.14084E+00_fp_kind, 0.14112E+00_fp_kind, 0.13789E+00_fp_kind,&
 0.13797E+00_fp_kind, 0.13794E+00_fp_kind, 0.13459E+00_fp_kind, 0.13439E+00_fp_kind, 0.13411E+00_fp_kind,&
 0.13374E+00_fp_kind, 0.13028E+00_fp_kind, 0.12978E+00_fp_kind, 0.12922E+00_fp_kind, 0.12858E+00_fp_kind,&
 0.12788E+00_fp_kind, 0.12434E+00_fp_kind, 0.12356E+00_fp_kind, 0.12272E+00_fp_kind, 0.12183E+00_fp_kind,&
 0.12089E+00_fp_kind, 0.11990E+00_fp_kind, 0.11886E+00_fp_kind, 0.11779E+00_fp_kind, 0.11667E+00_fp_kind,&
 0.11551E+00_fp_kind, 0.11432E+00_fp_kind, 0.11309E+00_fp_kind, 0.11422E+00_fp_kind, 0.11289E+00_fp_kind,&
 0.11154E+00_fp_kind, 0.11015E+00_fp_kind, 0.10873E+00_fp_kind, 0.10729E+00_fp_kind, 0.10808E+00_fp_kind,&
 0.10656E+00_fp_kind, 0.10501E+00_fp_kind, 0.10566E+00_fp_kind, 0.10403E+00_fp_kind, 0.10239E+00_fp_kind,&
 0.10290E+00_fp_kind, 0.10119E+00_fp_kind, 0.99456E-01_fp_kind, 0.99836E-01_fp_kind, 0.98041E-01_fp_kind,&
 0.98340E-01_fp_kind, 0.96485E-01_fp_kind, 0.96706E-01_fp_kind, 0.94793E-01_fp_kind, 0.94939E-01_fp_kind,&
 0.92971E-01_fp_kind, 0.93043E-01_fp_kind, 0.91024E-01_fp_kind, 0.91024E-01_fp_kind, 0.88954E-01_fp_kind,&
 0.88885E-01_fp_kind, 0.88785E-01_fp_kind, 0.86630E-01_fp_kind, 0.86462E-01_fp_kind, 0.86265E-01_fp_kind,&
 0.86038E-01_fp_kind, 0.83767E-01_fp_kind, 0.83476E-01_fp_kind, 0.83155E-01_fp_kind, 0.82805E-01_fp_kind/

DATA (sdd(35,j),j=1,100) / &
 0.10072E+00_fp_kind, 0.11461E+00_fp_kind, 0.12145E+00_fp_kind, 0.12902E+00_fp_kind, 0.13594E+00_fp_kind,&
 0.13992E+00_fp_kind, 0.14332E+00_fp_kind, 0.14769E+00_fp_kind, 0.14973E+00_fp_kind, 0.15131E+00_fp_kind,&
 0.15255E+00_fp_kind, 0.15477E+00_fp_kind, 0.15563E+00_fp_kind, 0.15654E+00_fp_kind, 0.15759E+00_fp_kind,&
 0.16320E+00_fp_kind, 0.16493E+00_fp_kind, 0.16605E+00_fp_kind, 0.16660E+00_fp_kind, 0.16665E+00_fp_kind,&
 0.16628E+00_fp_kind, 0.16552E+00_fp_kind, 0.16443E+00_fp_kind, 0.16305E+00_fp_kind, 0.16143E+00_fp_kind,&
 0.15960E+00_fp_kind, 0.15759E+00_fp_kind, 0.15544E+00_fp_kind, 0.15747E+00_fp_kind, 0.15495E+00_fp_kind,&
 0.15235E+00_fp_kind, 0.15372E+00_fp_kind, 0.15087E+00_fp_kind, 0.15188E+00_fp_kind, 0.14885E+00_fp_kind,&
 0.14954E+00_fp_kind, 0.14638E+00_fp_kind, 0.14680E+00_fp_kind, 0.14354E+00_fp_kind, 0.14374E+00_fp_kind,&
 0.14042E+00_fp_kind, 0.14041E+00_fp_kind, 0.14031E+00_fp_kind, 0.13688E+00_fp_kind, 0.13661E+00_fp_kind,&
 0.13626E+00_fp_kind, 0.13583E+00_fp_kind, 0.13229E+00_fp_kind, 0.13174E+00_fp_kind, 0.13112E+00_fp_kind,&
 0.13043E+00_fp_kind, 0.12967E+00_fp_kind, 0.12886E+00_fp_kind, 0.12522E+00_fp_kind, 0.12433E+00_fp_kind,&
 0.12338E+00_fp_kind, 0.12239E+00_fp_kind, 0.12135E+00_fp_kind, 0.12026E+00_fp_kind, 0.11913E+00_fp_kind,&
 0.11796E+00_fp_kind, 0.11926E+00_fp_kind, 0.11798E+00_fp_kind, 0.11666E+00_fp_kind, 0.11532E+00_fp_kind,&
 0.11393E+00_fp_kind, 0.11252E+00_fp_kind, 0.11108E+00_fp_kind, 0.11195E+00_fp_kind, 0.11042E+00_fp_kind,&
 0.10886E+00_fp_kind, 0.10728E+00_fp_kind, 0.10794E+00_fp_kind, 0.10628E+00_fp_kind, 0.10459E+00_fp_kind,&
 0.10511E+00_fp_kind, 0.10336E+00_fp_kind, 0.10158E+00_fp_kind, 0.10197E+00_fp_kind, 0.10012E+00_fp_kind,&
 0.10043E+00_fp_kind, 0.98519E-01_fp_kind, 0.98740E-01_fp_kind, 0.96773E-01_fp_kind, 0.96915E-01_fp_kind,&
 0.94891E-01_fp_kind, 0.94956E-01_fp_kind, 0.92877E-01_fp_kind, 0.92868E-01_fp_kind, 0.92826E-01_fp_kind,&
 0.90654E-01_fp_kind, 0.90540E-01_fp_kind, 0.90395E-01_fp_kind, 0.88135E-01_fp_kind, 0.87920E-01_fp_kind,&
 0.87674E-01_fp_kind, 0.87398E-01_fp_kind, 0.85019E-01_fp_kind, 0.84675E-01_fp_kind, 0.84302E-01_fp_kind/

DATA (sdd(36,j),j=1,100) / &
 0.10672E+00_fp_kind, 0.11612E+00_fp_kind, 0.12438E+00_fp_kind, 0.13286E+00_fp_kind, 0.13818E+00_fp_kind,&
 0.14496E+00_fp_kind, 0.14877E+00_fp_kind, 0.15026E+00_fp_kind, 0.15288E+00_fp_kind, 0.15498E+00_fp_kind,&
 0.15670E+00_fp_kind, 0.15819E+00_fp_kind, 0.15958E+00_fp_kind, 0.16100E+00_fp_kind, 0.16257E+00_fp_kind,&
 0.16638E+00_fp_kind, 0.16825E+00_fp_kind, 0.16948E+00_fp_kind, 0.17013E+00_fp_kind, 0.17028E+00_fp_kind,&
 0.16998E+00_fp_kind, 0.16929E+00_fp_kind, 0.16826E+00_fp_kind, 0.16693E+00_fp_kind, 0.16534E+00_fp_kind,&
 0.16355E+00_fp_kind, 0.16156E+00_fp_kind, 0.16397E+00_fp_kind, 0.16156E+00_fp_kind, 0.15904E+00_fp_kind,&
 0.16070E+00_fp_kind, 0.15789E+00_fp_kind, 0.15503E+00_fp_kind, 0.15611E+00_fp_kind, 0.15306E+00_fp_kind,&
 0.15381E+00_fp_kind, 0.15062E+00_fp_kind, 0.15109E+00_fp_kind, 0.14779E+00_fp_kind, 0.14803E+00_fp_kind,&
 0.14466E+00_fp_kind, 0.14469E+00_fp_kind, 0.14462E+00_fp_kind, 0.14113E+00_fp_kind, 0.14089E+00_fp_kind,&
 0.14055E+00_fp_kind, 0.14014E+00_fp_kind, 0.13653E+00_fp_kind, 0.13598E+00_fp_kind, 0.13536E+00_fp_kind,&
 0.13467E+00_fp_kind, 0.13392E+00_fp_kind, 0.13310E+00_fp_kind, 0.12937E+00_fp_kind, 0.12847E+00_fp_kind,&
 0.12751E+00_fp_kind, 0.12650E+00_fp_kind, 0.12544E+00_fp_kind, 0.12433E+00_fp_kind, 0.12317E+00_fp_kind,&
 0.12197E+00_fp_kind, 0.12073E+00_fp_kind, 0.12201E+00_fp_kind, 0.12066E+00_fp_kind, 0.11927E+00_fp_kind,&
 0.11785E+00_fp_kind, 0.11639E+00_fp_kind, 0.11490E+00_fp_kind, 0.11338E+00_fp_kind, 0.11422E+00_fp_kind,&
 0.11261E+00_fp_kind, 0.11097E+00_fp_kind, 0.11166E+00_fp_kind, 0.10994E+00_fp_kind, 0.10819E+00_fp_kind,&
 0.10873E+00_fp_kind, 0.10690E+00_fp_kind, 0.10506E+00_fp_kind, 0.10545E+00_fp_kind, 0.10354E+00_fp_kind,&
 0.10384E+00_fp_kind, 0.10186E+00_fp_kind, 0.10208E+00_fp_kind, 0.10003E+00_fp_kind, 0.10017E+00_fp_kind,&
 0.98063E-01_fp_kind, 0.98121E-01_fp_kind, 0.95952E-01_fp_kind, 0.95932E-01_fp_kind, 0.95877E-01_fp_kind,&
 0.93609E-01_fp_kind, 0.93479E-01_fp_kind, 0.93315E-01_fp_kind, 0.90953E-01_fp_kind, 0.90716E-01_fp_kind,&
 0.90447E-01_fp_kind, 0.87996E-01_fp_kind, 0.87655E-01_fp_kind, 0.87283E-01_fp_kind, 0.86879E-01_fp_kind/

DATA (sdd(37,j),j=1,100) / &
 0.10361E+00_fp_kind, 0.11599E+00_fp_kind, 0.12895E+00_fp_kind, 0.13494E+00_fp_kind, 0.14086E+00_fp_kind,&
 0.14610E+00_fp_kind, 0.15050E+00_fp_kind, 0.15410E+00_fp_kind, 0.15701E+00_fp_kind, 0.15797E+00_fp_kind,&
 0.16003E+00_fp_kind, 0.16184E+00_fp_kind, 0.16356E+00_fp_kind, 0.16427E+00_fp_kind, 0.16528E+00_fp_kind,&
 0.17315E+00_fp_kind, 0.17507E+00_fp_kind, 0.17040E+00_fp_kind, 0.17116E+00_fp_kind, 0.17141E+00_fp_kind,&
 0.17121E+00_fp_kind, 0.17061E+00_fp_kind, 0.16966E+00_fp_kind, 0.16841E+00_fp_kind, 0.16689E+00_fp_kind,&
 0.17001E+00_fp_kind, 0.16794E+00_fp_kind, 0.16572E+00_fp_kind, 0.16336E+00_fp_kind, 0.16532E+00_fp_kind,&
 0.16262E+00_fp_kind, 0.15984E+00_fp_kind, 0.16116E+00_fp_kind, 0.15815E+00_fp_kind, 0.15911E+00_fp_kind,&
 0.15593E+00_fp_kind, 0.15658E+00_fp_kind, 0.15327E+00_fp_kind, 0.15366E+00_fp_kind, 0.15026E+00_fp_kind,&
 0.15041E+00_fp_kind, 0.14695E+00_fp_kind, 0.14691E+00_fp_kind, 0.14676E+00_fp_kind, 0.14319E+00_fp_kind,&
 0.14288E+00_fp_kind, 0.14248E+00_fp_kind, 0.14200E+00_fp_kind, 0.13832E+00_fp_kind, 0.13771E+00_fp_kind,&
 0.13704E+00_fp_kind, 0.13629E+00_fp_kind, 0.13547E+00_fp_kind, 0.13460E+00_fp_kind, 0.13366E+00_fp_kind,&
 0.13267E+00_fp_kind, 0.12883E+00_fp_kind, 0.12776E+00_fp_kind, 0.12664E+00_fp_kind, 0.12548E+00_fp_kind,&
 0.12693E+00_fp_kind, 0.12564E+00_fp_kind, 0.12432E+00_fp_kind, 0.12295E+00_fp_kind, 0.12154E+00_fp_kind,&
 0.12009E+00_fp_kind, 0.11861E+00_fp_kind, 0.11710E+00_fp_kind, 0.11802E+00_fp_kind, 0.11641E+00_fp_kind,&
 0.11476E+00_fp_kind, 0.11309E+00_fp_kind, 0.11379E+00_fp_kind, 0.11203E+00_fp_kind, 0.11025E+00_fp_kind,&
 0.11079E+00_fp_kind, 0.10893E+00_fp_kind, 0.10704E+00_fp_kind, 0.10743E+00_fp_kind, 0.10547E+00_fp_kind,&
 0.10578E+00_fp_kind, 0.10374E+00_fp_kind, 0.10396E+00_fp_kind, 0.10186E+00_fp_kind, 0.10199E+00_fp_kind,&
 0.99824E-01_fp_kind, 0.99873E-01_fp_kind, 0.99886E-01_fp_kind, 0.97612E-01_fp_kind, 0.97544E-01_fp_kind,&
 0.95212E-01_fp_kind, 0.95066E-01_fp_kind, 0.94885E-01_fp_kind, 0.92454E-01_fp_kind, 0.92197E-01_fp_kind,&
 0.91906E-01_fp_kind, 0.91582E-01_fp_kind, 0.89018E-01_fp_kind, 0.88620E-01_fp_kind, 0.88190E-01_fp_kind/

DATA (sdd(38,j),j=1,100) / &
 0.10910E+00_fp_kind, 0.12163E+00_fp_kind, 0.13154E+00_fp_kind, 0.13845E+00_fp_kind, 0.14505E+00_fp_kind,&
 0.15082E+00_fp_kind, 0.15383E+00_fp_kind, 0.15798E+00_fp_kind, 0.15984E+00_fp_kind, 0.16274E+00_fp_kind,&
 0.16390E+00_fp_kind, 0.16620E+00_fp_kind, 0.16726E+00_fp_kind, 0.16852E+00_fp_kind, 0.17301E+00_fp_kind,&
 0.17583E+00_fp_kind, 0.17790E+00_fp_kind, 0.17928E+00_fp_kind, 0.18005E+00_fp_kind, 0.18029E+00_fp_kind,&
 0.18005E+00_fp_kind, 0.17940E+00_fp_kind, 0.17838E+00_fp_kind, 0.17706E+00_fp_kind, 0.17546E+00_fp_kind,&
 0.17363E+00_fp_kind, 0.17160E+00_fp_kind, 0.16941E+00_fp_kind, 0.17173E+00_fp_kind, 0.16914E+00_fp_kind,&
 0.16645E+00_fp_kind, 0.16369E+00_fp_kind, 0.16508E+00_fp_kind, 0.16207E+00_fp_kind, 0.16310E+00_fp_kind,&
 0.15991E+00_fp_kind, 0.16062E+00_fp_kind, 0.15729E+00_fp_kind, 0.15773E+00_fp_kind, 0.15429E+00_fp_kind,&
 0.15449E+00_fp_kind, 0.15099E+00_fp_kind, 0.15098E+00_fp_kind, 0.15086E+00_fp_kind, 0.14724E+00_fp_kind,&
 0.14696E+00_fp_kind, 0.14658E+00_fp_kind, 0.14611E+00_fp_kind, 0.14236E+00_fp_kind, 0.14176E+00_fp_kind,&
 0.14109E+00_fp_kind, 0.14034E+00_fp_kind, 0.13953E+00_fp_kind, 0.13864E+00_fp_kind, 0.13770E+00_fp_kind,&
 0.13379E+00_fp_kind, 0.13276E+00_fp_kind, 0.13168E+00_fp_kind, 0.13054E+00_fp_kind, 0.12935E+00_fp_kind,&
 0.12811E+00_fp_kind, 0.12954E+00_fp_kind, 0.12818E+00_fp_kind, 0.12678E+00_fp_kind, 0.12533E+00_fp_kind,&
 0.12385E+00_fp_kind, 0.12232E+00_fp_kind, 0.12076E+00_fp_kind, 0.12171E+00_fp_kind, 0.12005E+00_fp_kind,&
 0.11836E+00_fp_kind, 0.11663E+00_fp_kind, 0.11735E+00_fp_kind, 0.11553E+00_fp_kind, 0.11369E+00_fp_kind,&
 0.11424E+00_fp_kind, 0.11231E+00_fp_kind, 0.11036E+00_fp_kind, 0.11076E+00_fp_kind, 0.10872E+00_fp_kind,&
 0.10903E+00_fp_kind, 0.10692E+00_fp_kind, 0.10713E+00_fp_kind, 0.10495E+00_fp_kind, 0.10508E+00_fp_kind,&
 0.10282E+00_fp_kind, 0.10286E+00_fp_kind, 0.10054E+00_fp_kind, 0.10050E+00_fp_kind, 0.10041E+00_fp_kind,&
 0.97983E-01_fp_kind, 0.97817E-01_fp_kind, 0.97615E-01_fp_kind, 0.95080E-01_fp_kind, 0.94798E-01_fp_kind,&
 0.94481E-01_fp_kind, 0.94128E-01_fp_kind, 0.93740E-01_fp_kind, 0.91021E-01_fp_kind, 0.90556E-01_fp_kind/

DATA (sdd(39,j),j=1,100) / &
 0.11321E+00_fp_kind, 0.12119E+00_fp_kind, 0.13251E+00_fp_kind, 0.14030E+00_fp_kind, 0.14751E+00_fp_kind,&
 0.15376E+00_fp_kind, 0.15715E+00_fp_kind, 0.15995E+00_fp_kind, 0.16377E+00_fp_kind, 0.16552E+00_fp_kind,&
 0.16704E+00_fp_kind, 0.16847E+00_fp_kind, 0.17109E+00_fp_kind, 0.17269E+00_fp_kind, 0.17958E+00_fp_kind,&
 0.18248E+00_fp_kind, 0.17828E+00_fp_kind, 0.17979E+00_fp_kind, 0.18069E+00_fp_kind, 0.18104E+00_fp_kind,&
 0.18091E+00_fp_kind, 0.18036E+00_fp_kind, 0.17944E+00_fp_kind, 0.17821E+00_fp_kind, 0.17669E+00_fp_kind,&
 0.17494E+00_fp_kind, 0.17795E+00_fp_kind, 0.17568E+00_fp_kind, 0.17326E+00_fp_kind, 0.17073E+00_fp_kind,&
 0.17261E+00_fp_kind, 0.16976E+00_fp_kind, 0.16683E+00_fp_kind, 0.16809E+00_fp_kind, 0.16495E+00_fp_kind,&
 0.16586E+00_fp_kind, 0.16255E+00_fp_kind, 0.16316E+00_fp_kind, 0.15972E+00_fp_kind, 0.16007E+00_fp_kind,&
 0.15654E+00_fp_kind, 0.15666E+00_fp_kind, 0.15307E+00_fp_kind, 0.15298E+00_fp_kind, 0.15279E+00_fp_kind,&
 0.14909E+00_fp_kind, 0.14874E+00_fp_kind, 0.14829E+00_fp_kind, 0.14776E+00_fp_kind, 0.14394E+00_fp_kind,&
 0.14328E+00_fp_kind, 0.14254E+00_fp_kind, 0.14173E+00_fp_kind, 0.14085E+00_fp_kind, 0.13991E+00_fp_kind,&
 0.13891E+00_fp_kind, 0.13784E+00_fp_kind, 0.13672E+00_fp_kind, 0.13555E+00_fp_kind, 0.13432E+00_fp_kind,&
 0.13304E+00_fp_kind, 0.13171E+00_fp_kind, 0.13033E+00_fp_kind, 0.12891E+00_fp_kind, 0.12745E+00_fp_kind,&
 0.12594E+00_fp_kind, 0.12439E+00_fp_kind, 0.12543E+00_fp_kind, 0.12378E+00_fp_kind, 0.12209E+00_fp_kind,&
 0.12036E+00_fp_kind, 0.12115E+00_fp_kind, 0.11933E+00_fp_kind, 0.11747E+00_fp_kind, 0.11559E+00_fp_kind,&
 0.11615E+00_fp_kind, 0.11418E+00_fp_kind, 0.11464E+00_fp_kind, 0.11258E+00_fp_kind, 0.11050E+00_fp_kind,&
 0.11080E+00_fp_kind, 0.10864E+00_fp_kind, 0.10885E+00_fp_kind, 0.10661E+00_fp_kind, 0.10673E+00_fp_kind,&
 0.10681E+00_fp_kind, 0.10445E+00_fp_kind, 0.10444E+00_fp_kind, 0.10201E+00_fp_kind, 0.10191E+00_fp_kind,&
 0.10177E+00_fp_kind, 0.99227E-01_fp_kind, 0.99005E-01_fp_kind, 0.98746E-01_fp_kind, 0.96095E-01_fp_kind,&
 0.95754E-01_fp_kind, 0.95376E-01_fp_kind, 0.94962E-01_fp_kind, 0.94512E-01_fp_kind, 0.91671E-01_fp_kind/

DATA (sdd(40,j),j=1,100) / &
 0.10699E+00_fp_kind, 0.12254E+00_fp_kind, 0.13395E+00_fp_kind, 0.14181E+00_fp_kind, 0.14910E+00_fp_kind,&
 0.15334E+00_fp_kind, 0.15885E+00_fp_kind, 0.16170E+00_fp_kind, 0.16403E+00_fp_kind, 0.16596E+00_fp_kind,&
 0.16895E+00_fp_kind, 0.17043E+00_fp_kind, 0.17197E+00_fp_kind, 0.17372E+00_fp_kind, 0.18179E+00_fp_kind,&
 0.18471E+00_fp_kind, 0.18045E+00_fp_kind, 0.18197E+00_fp_kind, 0.18287E+00_fp_kind, 0.18322E+00_fp_kind,&
 0.18309E+00_fp_kind, 0.18253E+00_fp_kind, 0.18159E+00_fp_kind, 0.18034E+00_fp_kind, 0.17881E+00_fp_kind,&
 0.17704E+00_fp_kind, 0.17506E+00_fp_kind, 0.17778E+00_fp_kind, 0.17534E+00_fp_kind, 0.17277E+00_fp_kind,&
 0.17011E+00_fp_kind, 0.17179E+00_fp_kind, 0.16884E+00_fp_kind, 0.16584E+00_fp_kind, 0.16694E+00_fp_kind,&
 0.16374E+00_fp_kind, 0.16451E+00_fp_kind, 0.16117E+00_fp_kind, 0.16166E+00_fp_kind, 0.15820E+00_fp_kind,&
 0.15844E+00_fp_kind, 0.15856E+00_fp_kind, 0.15494E+00_fp_kind, 0.15485E+00_fp_kind, 0.15466E+00_fp_kind,&
 0.15092E+00_fp_kind, 0.15056E+00_fp_kind, 0.15011E+00_fp_kind, 0.14630E+00_fp_kind, 0.14571E+00_fp_kind,&
 0.14504E+00_fp_kind, 0.14430E+00_fp_kind, 0.14348E+00_fp_kind, 0.14260E+00_fp_kind, 0.14164E+00_fp_kind,&
 0.13765E+00_fp_kind, 0.13661E+00_fp_kind, 0.13551E+00_fp_kind, 0.13435E+00_fp_kind, 0.13314E+00_fp_kind,&
 0.13188E+00_fp_kind, 0.13335E+00_fp_kind, 0.13196E+00_fp_kind, 0.13052E+00_fp_kind, 0.12904E+00_fp_kind,&
 0.12752E+00_fp_kind, 0.12595E+00_fp_kind, 0.12435E+00_fp_kind, 0.12533E+00_fp_kind, 0.12362E+00_fp_kind,&
 0.12187E+00_fp_kind, 0.12009E+00_fp_kind, 0.12083E+00_fp_kind, 0.11895E+00_fp_kind, 0.11704E+00_fp_kind,&
 0.11761E+00_fp_kind, 0.11561E+00_fp_kind, 0.11359E+00_fp_kind, 0.11400E+00_fp_kind, 0.11189E+00_fp_kind,&
 0.11219E+00_fp_kind, 0.11001E+00_fp_kind, 0.11022E+00_fp_kind, 0.10795E+00_fp_kind, 0.10807E+00_fp_kind,&
 0.10573E+00_fp_kind, 0.10576E+00_fp_kind, 0.10335E+00_fp_kind, 0.10328E+00_fp_kind, 0.10318E+00_fp_kind,&
 0.10066E+00_fp_kind, 0.10047E+00_fp_kind, 0.10024E+00_fp_kind, 0.97603E-01_fp_kind, 0.97294E-01_fp_kind,&
 0.96947E-01_fp_kind, 0.96564E-01_fp_kind, 0.96144E-01_fp_kind, 0.93309E-01_fp_kind, 0.92808E-01_fp_kind/


CONTAINS

!################################################################################
!################################################################################
!##                                                                            ##
!##                         ## PUBLIC MODULE ROUTINES ##                       ##
!##                                                                            ##
!################################################################################
!################################################################################


!-------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       OCEANEM_AMSRE
!
! PURPOSE:
!       Subroutine to compute ocean emissivity
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL OCEANEM_AMSRE
!
! INPUT ARGUMENTS:
!
!         Frequency                Frequency User defines
!                                  This is the "I" dimension
!                                  UNITS:      GHz
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!
!         Sat_Zenith_Angle         The angle values in degree
!                                  ** NOTE: THIS IS A MANDATORY MEMBER **
!                                  **       OF THIS STRUCTURE          **
!                                  UNITS:      Degrees
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Rank-1, (I)
!
!         Surface_Temperature      Ocean surface temperature
!                                  UNITS:      Kelvin, K
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Wind_Speed               Ocean surface wind speed
!                                  UNITS:      m/s
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!
! OUTPUT ARGUMENTS:
! 
!         Emissivity:              The surface emissivity at vertical and horizontal polarizations.
!                                  ** NOTE: THIS IS A MANDATORY MEMBER **
!                                  **       OF THIS STRUCTURE          **
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  ONE
!
!
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!M-
!------------------------------------------------------------------------------------------------------------
!
  SUBROUTINE OCEANEM_AMSRE(Frequency,                                         & ! INPUT
                           Sat_Zenith_Angle,                                  & ! INPUT
                           Surface_Temperature,                               & ! INPUT
                           Wind_Speed,                                        & ! INPUT
                           Emissivity)                                          ! OUTPUT
!------------------------------------------------------------------------------------------------------------
!
  IMPLICIT NONE

!
! Declare passed variables.
!
  REAL( fp_kind ), INTENT( IN ) ::  Frequency, Sat_Zenith_Angle
  REAL( fp_kind ), INTENT( IN ) ::  Surface_Temperature, Wind_Speed
  REAL( fp_kind ), INTENT( OUT ) :: Emissivity(4)

!
! Declare local variables
!
  INTEGER i,j

  REAL(fp_kind) frequency_sdd(100),wind_speed_sdd(40)
  REAL(fp_kind) freq,x1,x2,y1,y2,sdd_intrp,satellite_zenith,salinity
  REAL(fp_kind) csl,csl2

  COMPLEX( fp_kind ) :: eps_ocean,Rvv,Rhh
  REAL(fp_kind) :: real_Rvv,imag_Rvv
  REAL(fp_kind) :: real_Rhh,imag_Rhh

  REAL(fp_kind) ::  wind,sst
  REAL(fp_kind) ::  Rv_Fresnel, Rh_Fresnel 
  REAL(fp_kind) ::  Rv_modified_fresnel, Rh_modified_fresnel
  REAL(fp_kind) ::  Fv, Fh, Rv_Foam, Rh_Foam, Foam_Coverage
  REAL(fp_kind) ::  Rv_Small,Rh_Small
  REAL(fp_kind) ::  Rv_Large,Rh_Large
  REAL(fp_kind) ::  Rv_Clear,Rh_Clear

  REAL(fp_kind) :: wind_index
  INTEGER Index_x,Index_y


  DO i = 1,40  ! Wind speed
    DO j = 1,100  ! Frequency
      frequency_sdd(j) = 1.0_fp_kind + 2.0_fp_kind * real(j)
      wind_speed_sdd(i) = 0.5_fp_kind + (real(i) - 1.0_fp_kind) * 0.5_fp_kind
    END DO
  END DO

  freq = Frequency
  wind = Wind_Speed
  sst = Surface_Temperature
  satellite_zenith = Sat_Zenith_Angle
  salinity = 35.0_fp_kind

  wind_index = wind
  IF(wind >= 20.0_fp_kind ) wind_index = 19.9_fp_kind
  IF(wind <= 2.0_fp_kind) wind_index = 2.001_fp_kind
  IF(freq >= 201.0_fp_kind) freq = 200.9_fp_kind
  IF(freq <= 3.0_fp_kind) freq = 3.1_fp_kind

  Index_x = int(wind_index)
  IF(Index_x < 1) Index_x = 1
  Index_y = int((freq - 1.0_fp_kind)/2.0_fp_kind)

  y1 = ( frequency_sdd(Index_y+1) - freq ) / 2.0_fp_kind
  y2 = ( freq - frequency_sdd(Index_y) ) / 2.0_fp_kind
  x1 = ( wind_speed_sdd(Index_x+1) - wind ) / 0.5_fp_kind
  x2 = ( wind - wind_speed_sdd(Index_x) ) / 0.5_fp_kind
  sdd_intrp = x2 * y2 * sdd(Index_x,Index_y) + x2 * y1 * sdd(Index_x,Index_y+1) + &
              x1 * y2 * sdd(Index_x+1,Index_y) + x1 * y1 * sdd(Index_x+1,Index_y+1)

!
!---- Permittivity Calculation
!
  IF(freq < 20.0_fp_kind) THEN
    CALL Compute_Guillou_eps_ocean(sst,salinity,freq,eps_ocean)
  ELSE
    CALL Compute_Ellison_eps_ocean(sst,salinity,freq,eps_ocean)
  END IF
  csl = cos(satellite_zenith*DEGREES_TO_RADIANS)
  csl2 = csl*csl


!
!---- Fresnel reflectivity Calculation
!
  call FRESNEL(eps_ocean,csl,Rv_Fresnel,Rh_Fresnel)


!
!---- Foam reflectivity Calculation
!
  Fv = 1.0_fp_kind - 9.946e-4_fp_kind*satellite_zenith+ &
       3.218e-5_fp_kind*satellite_zenith**2 -1.187e-6_fp_kind*satellite_zenith**3+ &
       7.e-20_fp_kind*satellite_zenith**10
  Rv_Foam = 0.07_fp_kind
  Fh = 1.0_fp_kind - 1.748e-3_fp_kind*satellite_zenith- &
       7.336e-5_fp_kind*satellite_zenith**2+1.044e-7_fp_kind*satellite_zenith**3
  Rh_Foam = 1.0_fp_kind - 0.93_fp_kind*Fh


!
!---- Foam Coverage Calculation
!
  IF(wind .lt. 7.0_fp_kind) THEN
     Foam_Coverage = 0.0_fp_kind
  ELSE
!     Foam_Coverage = 0.006_fp_kind*(1.0_fp_kind-exp(-freq*1.0e-9/7.5_fp_kind))*(wind-7.0_fp_kind)
     Foam_Coverage = 7.751e-6_fp_kind*wind**3.231
  END IF


!
!---- Small Scale Correction Calculation
!
  IF ( freq > 15.0_fp_kind) THEN
    Rv_Small = exp( - sdd_intrp * csl2)
    Rh_Small = exp( - sdd_intrp * csl2)
  ELSE
    Rv_Small = 1.0_fp_kind
    Rh_Small = 1.0_fp_kind
  END IF


!
!---- Modified Fresnel reflectivity Calculation
!
  Rv_modified_fresnel = Rv_Fresnel * Rv_Small
  Rh_modified_fresnel = Rh_Fresnel * Rh_Small


!
!---- Large Scale Correction Calculation
!
  Rv_Large = wind * ( Coeff(1) + Coeff(2) * satellite_zenith + &
            Coeff(3) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)
  Rh_Large = wind * ( Coeff(4) + Coeff(5) * satellite_zenith + &
            Coeff(6) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)


!
!---- Foam Clear Reflectivity Calculation
!
  Rv_Clear = Rv_modified_fresnel + Rv_Large 
  Rh_Clear = Rh_modified_fresnel + Rh_Large 


!
!---- Emissivity Calculation
!
  Emissivity(1) = 1.0_fp_kind - ( 1.0_fp_kind - Foam_Coverage )* Rv_Clear - Foam_Coverage * Rv_Foam
  Emissivity(2) = 1.0_fp_kind - ( 1.0_fp_kind - Foam_Coverage )* Rh_Clear - Foam_Coverage * Rh_Foam

  RETURN   


 END SUBROUTINE OCEANEM_AMSRE
!
!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       OCEANEM_AMSRE_TL
!
! PURPOSE:
!       Subroutine to compute ocean emissivity tangent liner
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL OCEANEM_AMSRE_TL
!
! INPUT ARGUMENTS:
!
!         Frequency                Frequency User defines
!                                  This is the "I" dimension
!                                  UNITS:      GHz
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Sat_Zenith_Angle         The angle values in degree
!                                  UNITS:      Degrees
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Rank-1, (I)
!
!         Surface_Temperature      Ocean surface temperature
!                                  UNITS:      Kelvin, K
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Surface_Temperature_tl   Ocean surface temperature tangent liner
!                                  UNITS:      Kelvin, K
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Wind_Speed               Ocean surface wind speed
!                                  UNITS:      m/s
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Wind_Speed_tl            Ocean surface wind speed tangent liner
!                                  UNITS:      m/s
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
! OUTPUT ARGUMENTS:
! 
!         Emissivity_tl            The surface emissivity tangent liner at vertical and horizontal polarizations.
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  ONE
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!M-
!------------------------------------------------------------------------------------------------------------
  SUBROUTINE OCEANEM_AMSRE_TL(Frequency,                                         & ! INPUT
                              Sat_Zenith_Angle,                                  & ! INPUT
                              Surface_Temperature,                               & ! INPUT
                              Surface_Temperature_tl,                            & ! INPUT
                              Wind_Speed,                                        & ! INPUT
                              Wind_Speed_tl,                                     & ! INPUT
                              Emissivity_tl)                                       ! OUTPUT)
!------------------------------------------------------------------------------------------------------------
!
  IMPLICIT NONE

!
! Declare passed variables.
!
  REAL( fp_kind ), INTENT( IN ) ::  Frequency, Sat_Zenith_Angle
  REAL( fp_kind ), INTENT( IN ) ::  Surface_Temperature,Surface_Temperature_tl, Wind_Speed,Wind_Speed_tl
  REAL( fp_kind ), INTENT( OUT ) ::  Emissivity_tl(4)

!
! Declare local variables
!
  INTEGER i,j

  REAL(fp_kind) frequency_sdd(100),wind_speed_sdd(40)
  REAL(fp_kind) freq,satellite_zenith,salinity

  REAL(fp_kind) x1,x2,y1,y2,sdd_intrp
  REAL(fp_kind) x1_tl,x2_tl,sdd_intrp_tl
  REAL(fp_kind) csl,csl2

  REAL(fp_kind) wind, wind_tl
  REAL(fp_kind) sst, sst_tl

  COMPLEX( fp_kind ) :: eps_ocean,Rvv,Rhh
  REAL(fp_kind) :: real_Rvv,imag_Rvv
  REAL(fp_kind) :: real_Rhh,imag_Rhh
  REAL(fp_kind) :: real_Rvv_tl,imag_Rvv_tl
  REAL(fp_kind) :: real_Rhh_tl,imag_Rhh_tl
  COMPLEX( fp_kind ) :: eps_ocean_tl,Rvv_tl,Rhh_tl

  REAL(fp_kind) ::  Rv_Fresnel, Rh_Fresnel 
  REAL(fp_kind) ::  Rv_modified_fresnel, Rh_modified_fresnel
  REAL(fp_kind) ::  Fv, Fh, Rv_Foam, Rh_Foam, Foam_Coverage
  REAL(fp_kind) ::  Rv_Small,Rh_Small
  REAL(fp_kind) ::  Rv_Large,Rh_Large
  REAL(fp_kind) ::  Rv_Clear,Rh_Clear

  REAL(fp_kind) ::  Rv_Fresnel_tl,Rh_Fresnel_tl
  REAL(fp_kind) ::  Rv_modified_fresnel_tl, Rh_modified_fresnel_tl
  REAL(fp_kind) ::  Rv_Foam_tl,Rh_Foam_tl, Foam_Coverage_tl
  REAL(fp_kind) ::  Rv_Small_tl,Rh_Small_tl
  REAL(fp_kind) ::  Rv_Large_tl,Rh_Large_tl
  REAL(fp_kind) ::  Rv_Clear_tl,Rh_Clear_tl

  REAL(fp_kind) :: wind_index
  INTEGER Index_x,Index_y


  DO i = 1,40  ! Wind speed
    DO j = 1,100  ! Frequency
      frequency_sdd(j) = 1.0_fp_kind + 2.0_fp_kind * real(j)
      wind_speed_sdd(i) = 0.5_fp_kind + (real(i) - 1.0_fp_kind) * 0.5_fp_kind
    END DO
  END DO

  freq = Frequency
  wind = Wind_Speed
  wind_tl = Wind_Speed_tl
  sst = Surface_Temperature
  sst_tl = Surface_Temperature_tl

  satellite_zenith = Sat_Zenith_Angle
  salinity = 35.0_fp_kind

  wind_index = wind
  IF(wind >= 20.0_fp_kind ) wind_index = 19.9_fp_kind
  IF(wind <= 2.0_fp_kind) wind_index = 2.001_fp_kind
  IF(freq >= 201.0_fp_kind) freq = 200.9_fp_kind
  IF(freq <= 3.0_fp_kind) freq = 3.1_fp_kind

  Index_x = int(wind_index)
  IF(Index_x < 1) Index_x = 1
  Index_y = int((freq - 1.0_fp_kind)/2.0_fp_kind)


  y1 = ( frequency_sdd(Index_y+1) - freq ) / 2.0_fp_kind
  y2 = ( freq - frequency_sdd(Index_y) ) / 2.0_fp_kind

  x1 = ( wind_speed_sdd(Index_x+1) - wind ) / 0.5_fp_kind
  x1_tl = ( - wind_tl ) / 0.5_fp_kind
  x2 = ( wind - wind_speed_sdd(Index_x) ) / 0.5_fp_kind
  x2_tl = ( wind_tl ) / 0.5_fp_kind

  sdd_intrp = x2 * y2 * sdd(Index_x,Index_y) + x2 * y1 * sdd(Index_x,Index_y+1) + &
              x1 * y2 * sdd(Index_x+1,Index_y) + x1 * y1 * sdd(Index_x+1,Index_y+1)
  sdd_intrp_tl = x2_tl * y2 * sdd(Index_x,Index_y) + x2_tl * y1 * sdd(Index_x,Index_y+1) + &
                 x1_tl * y2 * sdd(Index_x+1,Index_y) + x1_tl * y1 * sdd(Index_x+1,Index_y+1)


!
!---- Permittivity Calculation
!
  IF(freq < 20.0_fp_kind) THEN
    CALL Compute_Guillou_eps_ocean(sst,salinity,freq,eps_ocean)
    CALL Compute_Guillou_eps_ocean_TL(sst,sst_tl,salinity,freq,eps_ocean,eps_ocean_tl)
  ELSE
    CALL Compute_Ellison_eps_ocean(sst,salinity,freq,eps_ocean)
    CALL Compute_Ellison_eps_ocean_TL(sst,sst_tl,salinity,freq,eps_ocean,eps_ocean_tl)
  END IF
  csl = cos(satellite_zenith*DEGREES_TO_RADIANS)
  csl2 = csl*csl


!
!---- Fresnel reflectivity Calculation
!
  call FRESNEL(eps_ocean,csl,Rv_Fresnel,Rh_Fresnel)
  call FRESNEL_TL(eps_ocean,eps_ocean_tl,csl,Rv_Fresnel,Rh_Fresnel,Rv_Fresnel_tl,Rh_Fresnel_tl)


!
!---- Foam reflectivity Calculation
!
  Fv = 1.0_fp_kind - 9.946e-4_fp_kind*satellite_zenith+ &
       3.218e-5_fp_kind*satellite_zenith**2 -1.187e-6_fp_kind*satellite_zenith**3+ &
       7.e-20_fp_kind*satellite_zenith**10
  Rv_Foam = 0.07_fp_kind
  Rv_Foam_tl =  0.0_fp_kind
  Fh = 1.0_fp_kind - 1.748e-3_fp_kind*satellite_zenith- &
       7.336e-5_fp_kind*satellite_zenith**2+1.044e-7_fp_kind*satellite_zenith**3
  Rh_Foam = 1.0_fp_kind - 0.93_fp_kind*Fh
  Rh_Foam_tl =  0.0_fp_kind


!
!---- Foam Coverage Calculation
!
  IF(wind .lt. 7.0_fp_kind) THEN
     Foam_Coverage = 0.0_fp_kind
  ELSE
!     Foam_Coverage = 0.006_fp_kind*(1.0_fp_kind-exp(-freq*1.0e-9/7.5_fp_kind))*(wind-7.0_fp_kind)
     Foam_Coverage = 7.751e-6_fp_kind*wind**3.231
  END IF

  IF(wind .lt. 7.0_fp_kind) THEN
     Foam_Coverage_tl = 0.0_fp_kind
  ELSE
!     Foam_Coverage_tl = 0.006_fp_kind*(1.0_fp_kind-exp(-freq*1.0e-9/7.5_fp_kind))*wind_tl
     Foam_Coverage_tl = 3.231_fp_kind * 7.751e-6_fp_kind*wind**2.231 * wind_tl
  END IF


!
!---- Small Scale Correction Calculation
!
  IF ( freq > 15.0_fp_kind) THEN
    Rv_Small = exp( - sdd_intrp * csl2)
    Rh_Small = exp( - sdd_intrp * csl2)
    Rv_Small_tl = -csl2 * exp( - sdd_intrp * csl2) * sdd_intrp_tl
    Rh_Small_tl = -csl2 * exp( - sdd_intrp * csl2) * sdd_intrp_tl
  ELSE
    Rv_Small = 1.0_fp_kind
    Rh_Small = 1.0_fp_kind
    Rv_Small_tl = 0.0_fp_kind
    Rh_Small_tl = 0.0_fp_kind
  END IF


!
!---- Modified Fresnel reflectivity Calculation
!
  Rv_modified_fresnel = Rv_Fresnel * Rv_Small
  Rh_modified_fresnel = Rh_Fresnel * Rh_Small

  Rv_modified_fresnel_tl = Rv_Fresnel_tl * Rv_Small + Rv_Fresnel * Rv_Small_tl
  Rh_modified_fresnel_tl = Rh_Fresnel_tl * Rh_Small + Rh_Fresnel * Rh_Small_tl

!
!---- Large Scale Correction Calculation
!
  Rv_Large = wind * ( Coeff(1) + Coeff(2) * satellite_zenith + &
            Coeff(3) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)
  Rh_Large = wind * ( Coeff(4) + Coeff(5) * satellite_zenith + &
            Coeff(6) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)

  Rv_Large_tl = wind_tl * ( Coeff(1) + Coeff(2) * satellite_zenith + &
                Coeff(3) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)
  Rh_Large_tl = wind_tl * ( Coeff(4) + Coeff(5) * satellite_zenith + &
                Coeff(6) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)

!
!---- Foam Clear Reflectivity Calculation
!
  Rv_Clear = Rv_modified_fresnel + Rv_Large
  Rh_Clear = Rh_modified_fresnel + Rh_Large
  Rv_Clear_tl = Rv_modified_fresnel_tl + Rv_Large_tl
  Rh_Clear_tl = Rh_modified_fresnel_tl + Rh_Large_tl

!
!---- Emissivity Calculation
!

  Emissivity_tl(1) =  - ( - Foam_Coverage_tl )* Rv_Clear  - &
                        ( 1.0_fp_kind - Foam_Coverage )* Rv_Clear_tl - &
                        Foam_Coverage_tl * Rv_Foam - Foam_Coverage * Rv_Foam_tl
  Emissivity_tl(2) =  - ( - Foam_Coverage_tl )* Rh_Clear  - &
                        ( 1.0_fp_kind - Foam_Coverage )* Rh_Clear_tl - &
                        Foam_Coverage_tl * Rh_Foam - Foam_Coverage * Rh_Foam_tl


  RETURN  


 END SUBROUTINE OCEANEM_AMSRE_TL
!
!!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       OCEANEM_AMSRE_AD
!
! PURPOSE:
!       Subroutine to compute ocean emissivity adjont
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL OCEANEM_AMSRE_AD
!
! INPUT ARGUMENTS:
!
!         Frequency                Frequency User defines
!                                  This is the "I" dimension
!                                  UNITS:      GHz
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Sat_Zenith_Angle         The angle values in degree
!                                  UNITS:      Degrees
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Rank-1, (I)
!
!         Surface_Temperature      Ocean surface temperature
!                                  UNITS:      Kelvin, K
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Wind_Speed               Ocean surface wind speed
!                                  UNITS:      m/s
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Emissivity_ad            The surface emissivity adjoint at vertical and horizontal polarizations.
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  ONE
!
! OUTPUT ARGUMENTS:
! 
!         Surface_Temperature_ad   Ocean surface temperature adjoint
!                                  UNITS:      Kelvin, K
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Wind_Speed_ad            Ocean surface wind speed adjoint
!                                  UNITS:      m/s
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
  SUBROUTINE OCEANEM_AMSRE_AD(Frequency,                                         & ! INPUT
                              Sat_Zenith_Angle,                                  & ! INPUT
                              Surface_Temperature,                               & ! INPUT
                              Surface_Temperature_ad,                            & ! INPUT/OUTPUT
                              Wind_Speed,                                        & ! INPUT
                              Wind_Speed_ad,                                     & ! INPUT/OUTPUT
                              Emissivity_ad)                                       ! INPUT)
!------------------------------------------------------------------------------------------------------------
  USE TYPE_Kinds
!
  IMPLICIT NONE
! Declare passed variables.
!
  REAL( fp_kind ), INTENT( IN ) ::  Frequency, Sat_Zenith_Angle
  REAL( fp_kind ), INTENT( IN ) ::  Surface_Temperature,Wind_Speed
  REAL( fp_kind ), INTENT( IN OUT ) ::  Surface_Temperature_ad,Wind_Speed_ad
  REAL( fp_kind ), INTENT( IN ) ::  Emissivity_ad(4)

!
! Declare local variables
!
  INTEGER i,j

  REAL(fp_kind) frequency_sdd(100),wind_speed_sdd(40)
  REAL(fp_kind) freq,satellite_zenith,salinity

  REAL(fp_kind) x1,x2,y1,y2,sdd_intrp
  REAL(fp_kind) x1_ad,x2_ad,sdd_intrp_ad

  REAL(fp_kind) csl,csl2

  REAL(fp_kind) ::  wind,wind_ad
  REAL(fp_kind) ::  sst,sst_ad

  COMPLEX( fp_kind ) :: eps_ocean,Rvv,Rhh
  COMPLEX( fp_kind ) :: eps_ocean_ad,Rvv_ad,Rhh_ad


  REAL(fp_kind) ::  Rv_Fresnel, Rh_Fresnel
  REAL(fp_kind) ::  Rv_modified_fresnel, Rh_modified_fresnel
  REAL(fp_kind) ::  Fv, Fh, Rv_Foam, Rh_Foam, Foam_Coverage
  REAL(fp_kind) ::  Rv_Small,Rh_Small
  REAL(fp_kind) ::  Rv_Large,Rh_Large
  REAL(fp_kind) ::  Rv_Clear,Rh_Clear

  REAL(fp_kind) ::  Rv_Fresnel_ad,Rh_Fresnel_ad
  REAL(fp_kind) ::  Rv_modified_fresnel_ad, Rh_modified_fresnel_ad
  REAL(fp_kind) ::  Rv_Foam_ad,Rh_Foam_ad, Foam_Coverage_ad
  REAL(fp_kind) ::  Rv_Small_ad,Rh_Small_ad
  REAL(fp_kind) ::  Rv_Large_ad,Rh_Large_ad
  REAL(fp_kind) ::  Rv_Clear_ad,Rh_Clear_ad

  REAL(fp_kind) :: real_Rhh,imag_Rhh
  REAL(fp_kind) :: real_Rvv,imag_Rvv
  REAL(fp_kind) :: real_Rhh_ad,imag_Rhh_ad
  REAL(fp_kind) :: real_Rvv_ad,imag_Rvv_ad

  REAL(fp_kind) :: wind_index
  INTEGER Index_x,Index_y

! Initialization
  wind_ad = 0.0_fp_kind
  sst_ad = 0.0_fp_kind
  x1_ad = 0.0_fp_kind
  x2_ad = 0.0_fp_kind
  sdd_intrp_ad = 0.0_fp_kind
  eps_ocean_ad = (0.0_fp_kind,0.0_fp_kind)
  Rvv_ad = (0.0_fp_kind,0.0_fp_kind)
  Rhh_ad = (0.0_fp_kind,0.0_fp_kind)
  Rv_Fresnel_ad = 0.0_fp_kind
  Rh_Fresnel_ad = 0.0_fp_kind
  Rv_modified_fresnel_ad = 0.0_fp_kind
  Rh_modified_fresnel_ad = 0.0_fp_kind
  Rv_Foam_ad = 0.0_fp_kind
  Rh_Foam_ad = 0.0_fp_kind
  Foam_Coverage_ad = 0.0_fp_kind
  Rv_Small_ad = 0.0_fp_kind
  Rh_Small_ad = 0.0_fp_kind
  Rv_Large_ad = 0.0_fp_kind
  Rh_Large_ad = 0.0_fp_kind
  real_Rhh_ad = 0.0_fp_kind
  imag_Rhh_ad = 0.0_fp_kind
  real_Rvv_ad = 0.0_fp_kind
  imag_Rvv_ad = 0.0_fp_kind

  Surface_Temperature_ad = 0.0_fp_kind
  Wind_Speed_ad = 0.0_fp_kind
!-----------------------------
!
!---- START Forward model ----
!
!-----------------------------
  DO i = 1,40  ! Wind speed
    DO j = 1,100  ! Frequency
      frequency_sdd(j) = 1.0_fp_kind + 2.0_fp_kind * real(j)
      wind_speed_sdd(i) = 0.5_fp_kind + (real(i) - 1.0_fp_kind) * 0.5_fp_kind
    END DO
  END DO

  freq = Frequency
  wind = Wind_Speed
  sst = Surface_Temperature
  satellite_zenith = Sat_Zenith_Angle
  salinity = 35.0_fp_kind

  wind_index = wind
  IF(wind >= 20.0_fp_kind ) wind_index = 19.9_fp_kind
  IF(wind <= 2.0_fp_kind) wind_index = 2.001_fp_kind
  IF(freq >= 201.0_fp_kind) freq = 200.9_fp_kind
  IF(freq <= 3.0_fp_kind) freq = 3.1_fp_kind

  Index_x = int(wind_index)
  IF(Index_x < 1) Index_x = 1
  Index_y = int((freq - 1.0_fp_kind)/2.0_fp_kind)

  y1 = ( frequency_sdd(Index_y+1) - freq ) / 2.0_fp_kind
  y2 = ( freq - frequency_sdd(Index_y) ) / 2.0_fp_kind
  x1 = ( wind_speed_sdd(Index_x+1) - wind ) / 0.5_fp_kind
  x2 = ( wind - wind_speed_sdd(Index_x) ) / 0.5_fp_kind
  sdd_intrp = x2 * y2 * sdd(Index_x,Index_y) + x2 * y1 * sdd(Index_x,Index_y+1) + &
              x1 * y2 * sdd(Index_x+1,Index_y) + x1 * y1 * sdd(Index_x+1,Index_y+1)

!
!---- Permittivity Calculation
!
  IF(freq < 20.0_fp_kind) THEN
    CALL Compute_Guillou_eps_ocean(sst,salinity,freq,eps_ocean)
  ELSE
    CALL Compute_Ellison_eps_ocean(sst,salinity,freq,eps_ocean)
  END IF
  csl = cos(satellite_zenith*DEGREES_TO_RADIANS)
  csl2 = csl*csl


!
!---- Fresnel reflectivity Calculation
!
  call FRESNEL(eps_ocean,csl,Rv_Fresnel,Rh_Fresnel)


!
!---- Foam reflectivity Calculation
!
  Fv = 1.0_fp_kind - 9.946e-4_fp_kind*satellite_zenith+ &
       3.218e-5_fp_kind*satellite_zenith**2 -1.187e-6_fp_kind*satellite_zenith**3+ &
       7.e-20_fp_kind*satellite_zenith**10
  Rv_Foam = 0.07_fp_kind
  Fh = 1.0_fp_kind - 1.748e-3_fp_kind*satellite_zenith- &
       7.336e-5_fp_kind*satellite_zenith**2+1.044e-7_fp_kind*satellite_zenith**3
  Rh_Foam = 1.0_fp_kind - 0.93_fp_kind*Fh


!
!---- Foam Coverage Calculation
!
  IF(wind .lt. 7.0_fp_kind) THEN
     Foam_Coverage = 0.0_fp_kind
  ELSE
!     Foam_Coverage = 0.006_fp_kind*(1.0_fp_kind-exp(-freq*1.0e-9/7.5_fp_kind))*(wind-7.0_fp_kind)
     Foam_Coverage = 7.751e-6_fp_kind*wind**3.231
  END IF


!
!---- Small Scale Correction Calculation
!
  IF ( freq > 15.0_fp_kind) THEN
    Rv_Small = exp( - sdd_intrp * csl2)
    Rh_Small = exp( - sdd_intrp * csl2)
  ELSE
    Rv_Small = 1.0_fp_kind
    Rh_Small = 1.0_fp_kind
  END IF


!
!---- Modified Fresnel reflectivity Calculation
!
  Rv_modified_fresnel = Rv_Fresnel * Rv_Small
  Rh_modified_fresnel = Rh_Fresnel * Rh_Small


!
!---- Large Scale Correction Calculation
!
  Rv_Large = wind * ( Coeff(1) + Coeff(2) * satellite_zenith + &
            Coeff(3) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)
  Rh_Large = wind * ( Coeff(4) + Coeff(5) * satellite_zenith + &
            Coeff(6) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)


!
!---- Foam Clear Reflectivity Calculation
!
  Rv_Clear = Rv_modified_fresnel + Rv_Large 
  Rh_Clear = Rh_modified_fresnel + Rh_Large 



!-----------------------------
!
!---- START Adjoint model ----
!
!-----------------------------
!
!
!---- Emissivity Calculation
!
   Foam_Coverage_ad =  + (Rh_Clear - Rh_Foam ) * Emissivity_ad(2)
   Rh_Clear_ad      =  - ( 1.0_fp_kind - Foam_Coverage ) * Emissivity_ad(2)
   Rh_Foam_ad       =  - Foam_Coverage * Emissivity_ad(2)

   Foam_Coverage_ad = Foam_Coverage_ad +  (Rv_Clear - Rv_Foam ) * Emissivity_ad(1)
   Rv_Clear_ad      =  -  ( 1.0_fp_kind - Foam_Coverage ) * Emissivity_ad(1)
   Rv_Foam_ad       =  - Foam_Coverage * Emissivity_ad(1)


!
!---- Foam Clear Reflectivity Calculation
!
   Rh_modified_fresnel_ad = Rh_Clear_ad
   Rh_Large_ad            = Rh_Clear_ad
   Rv_modified_fresnel_ad = Rv_Clear_ad
   Rv_Large_ad            = Rv_Clear_ad


!
!---- Large Scale Correction Calculation
!
   wind_ad = ( Coeff(4) + Coeff(5) * satellite_zenith + &
               Coeff(6) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)*Rh_Large_ad
   wind_ad = wind_ad + ( Coeff(1) + Coeff(2) * satellite_zenith + &
               Coeff(3) * satellite_zenith*satellite_zenith ) * freq/(Coeff(7) + Coeff(8)*freq)*Rv_Large_ad


!
!---- Modified Fresnel reflectivity Calculation
!
   Rh_Fresnel_ad = Rh_Small   * Rh_modified_fresnel_ad
   Rh_Small_ad   = Rh_Fresnel * Rh_modified_fresnel_ad
   Rv_Fresnel_ad = Rv_Small   * Rv_modified_fresnel_ad
   Rv_Small_ad   = Rv_Fresnel * Rv_modified_fresnel_ad


!
!---- Small Scale Correction Calculation
!
  IF ( freq > 15.0_fp_kind) THEN  
   sdd_intrp_ad = - csl2 * exp( - sdd_intrp * csl2) * Rh_Small_ad
   sdd_intrp_ad = sdd_intrp_ad  -csl2  * exp( - sdd_intrp * csl2)  * Rv_Small_ad
  ELSE
   sdd_intrp_ad = 0.0_fp_kind
  END IF


!
!---- Foam Coverage Calculation
!
   IF(wind .ge. 7.0_fp_kind) THEN
!     wind_ad = wind_ad + ( 0.006_fp_kind*(1.0_fp_kind-exp(-freq*1.0e-9/7.5_fp_kind)) ) * Foam_Coverage_ad
     wind_ad = wind_ad + (3.231_fp_kind * 7.751e-6_fp_kind*wind**2.231 ) * Foam_Coverage_ad
   END IF

!
!---- Foam reflectivity Calculation
!

!   SST_ad = ((208.0_fp_kind+1.29e-9_fp_kind*freq)/SST**2)*Fh * Rh_Foam_ad
!   SST_ad = SST_ad +  ((208.0_fp_kind+1.29e-9_fp_kind*freq)/SST**2)*Fv * Rv_Foam_ad



!
!---- Fresnel reflectivity Calculation
!
  call FRESNEL_AD(eps_ocean,eps_ocean_ad,csl,Rv_Fresnel,Rh_Fresnel,Rv_Fresnel_ad,Rh_Fresnel_ad)


!
!---- Permittivity Calculation
!
  IF(freq < 20.0_fp_kind) THEN
    CALL Compute_Guillou_eps_ocean_AD(sst,sst_ad,salinity,freq,eps_ocean,eps_ocean_ad)
  ELSE
    CALL Compute_Ellison_eps_ocean_AD(sst,sst_ad,salinity,freq,eps_ocean,eps_ocean_ad)
  END IF


  x2_ad =  ( y2 * sdd(Index_x,Index_y) +  y1 * sdd(Index_x,Index_y+1) ) * sdd_intrp_ad
  x1_ad =  ( y2 * sdd(Index_x+1,Index_y) + y1 * sdd(Index_x+1,Index_y+1) )  * sdd_intrp_ad

  wind_ad = wind_ad + x2_ad/0.5_fp_kind
  wind_ad = wind_ad - x1_ad/0.5_fp_kind


  Surface_Temperature_ad =  sst_ad
  Wind_Speed_ad =  wind_ad


  RETURN

END SUBROUTINE OCEANEM_AMSRE_AD

!
!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       Compute_Ellison_eps_ocean
!
! PURPOSE:
!       Subroutine to compute ocean permittivity
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL Compute_Ellison_eps_ocean
!
! INPUT ARGUMENTS:
!
!         SST                      Sea Surface Temperature
!                                  UNITS:      Kelvin, K
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         S                        Salinity
!                                  UNITS:      parts per thousand
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         f                        Frequency
!                                  UNITS:      GHz
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
! OUTPUT ARGUMENTS:
! 
!         eps_ocean                Ocean permittivity
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
! Reference:
!
!  Ellison, W. J. et al. (2003) A comparison of ocean emissivity models using the Advanced Microwave Sounding Unit,
!                               the Special Sensor Microwave Imager, the TRMM Microwave Imager, and 
!                               airborne radiometer observations. Journal of Geophysical Research, 108, 4663
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
  SUBROUTINE Compute_Ellison_eps_ocean(SST, & ! Input, Water temperature in Kelvin
                                       S, & ! Input, Salinity in parts per thousand
                                       f, & ! Input, Frequency in GHz
                                       eps_ocean) ! Output, permitivity
!------------------------------------------------------------------------------------------------------------
  USE Type_Kinds
  IMPLICIT NONE
  REAL( fp_kind ), INTENT( IN ) :: SST, S, F
  COMPLEX( fp_kind ), INTENT( OUT ) :: eps_ocean

  ! internal variables
  REAL( fp_kind ) :: t,t2,eswi,eo,eswo,a,b,d,esw,tswo,tsw,sswo,fi,ssw,eps_imag,eps_real
  REAL( fp_kind ) :: fen,fen_sq,den1,den2,perm_real1,perm_real2,perm_imag1,perm_imag2
  REAL( fp_kind ) :: tcelsius,tcelsius_sq,tcelsius_cu,f1,f2,del1,del2,einf
  REAL( fp_kind ) :: perm_free,sigma,perm_imag3,perm_Real,perm_imag

    !-----------------------------------------------------
    !1.2 calculate permittivity using double-debye formula
    !-----------------------------------------------------
    !Set values for temperature polynomials (convert from kelvin to celsius)
    tcelsius = SST - 273.15_fp_kind
    tcelsius_sq = tcelsius * tcelsius     !quadratic
    tcelsius_cu = tcelsius_sq * tcelsius  !cubic

    !Define two relaxation frequencies, f1 and f2
    f1 = 17.5350_fp_kind - 0.617670_fp_kind * tcelsius + 0.00894800_fp_kind * tcelsius_sq
    f2 = 3.18420_fp_kind + 0.0191890_fp_kind * tcelsius - 0.0108730_fp_kind * tcelsius_sq + 0.000258180_fp_kind * tcelsius_cu

    !Static permittivity estatic = del1+del2+einf
    del1 = 68.3960_fp_kind - 0.406430_fp_kind * tcelsius + 0.0228320_fp_kind * tcelsius_sq - 0.000530610_fp_kind * tcelsius_cu
    del2 = 4.76290_fp_kind + 0.154100_fp_kind * tcelsius - 0.0337170_fp_kind * tcelsius_sq + 0.000844280_fp_kind * tcelsius_cu
    einf = 5.31250_fp_kind - 0.0114770_fp_kind * tcelsius
    fen          = 2.0_fp_kind * PI * f * 0.001_fp_kind
    fen_sq       = fen*fen
    den1         = 1.0_fp_kind + fen_sq * f1 * f1
    den2         = 1.0_fp_kind + fen_sq * f2 * f2
    perm_real1   = del1 / den1
    perm_real2   = del2 / den2
    perm_imag1   = del1 * fen * f1 / den1
    perm_imag2   = del2 * fen * f2 / den2
    ! perm_free = 8.854E-3_fp_kind not 8.854E-12 as multiplied by 1E9 for GHz
    perm_free    = 8.854E-3_fp_kind
    sigma        = 2.906_fp_kind + 0.09437_fp_kind * tcelsius
    perm_imag3   = sigma / (2.0_fp_kind * PI * perm_free * f)
    perm_Real    = perm_real1 + perm_real2 + einf
    perm_imag    = perm_imag1 + perm_imag2 + perm_imag3
    eps_ocean = cmplx(perm_Real,perm_imag,fp_kind)

  RETURN
 END SUBROUTINE Compute_Ellison_eps_ocean
!
!
!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       Compute_Ellison_eps_ocean_TL
!
! PURPOSE:
!       Subroutine to compute ocean permittivity tangent liner
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL Compute_Ellison_eps_ocean_TL
!
! INPUT ARGUMENTS:
!
!         SST                      Sea Surface Temperature
!                                  UNITS:      Kelvin, K
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         SST_tl                   Sea Surface Temperature tangent liner
!                                  UNITS:      Kelvin, K
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         S                        Salinity
!                                  UNITS:      parts per thousand
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         f                        Frequency
!                                  UNITS:      GHz
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
! OUTPUT ARGUMENTS:
! 
!         eps_ocean                Ocean permittivity
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
!         eps_ocean_tl             Ocean permittivity tangent liner
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
! Reference:
!
!  Ellison, W. J. et al. (2003) A comparison of ocean emissivity models using the Advanced Microwave Sounding Unit,
!                               the Special Sensor Microwave Imager, the TRMM Microwave Imager, and 
!                               airborne radiometer observations. Journal of Geophysical Research, 108, 4663
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
  SUBROUTINE Compute_Ellison_eps_ocean_TL(SST, & ! Input, Water temperature in Kelvin
                                          SST_tl, & 
                                          S, & ! Input, Salinity in parts per thousand
                                          f, & ! Input, Frequency in GHz
                                          eps_ocean, & ! Output, permitivity
                                          eps_ocean_tl) ! Output
!------------------------------------------------------------------------------------------------------------
  USE Type_Kinds
  IMPLICIT NONE
  REAL( fp_kind ), INTENT( IN ) :: SST, SST_tl, S, F
  COMPLEX( fp_kind ), INTENT( OUT ) :: eps_ocean,eps_ocean_tl

  ! internal variables
  REAL( fp_kind ) :: t,t2,eswi,eo,eswo,a,b,d,esw,tswo,tsw,sswo,fi,ssw,eps_imag,eps_real
  REAL( fp_kind ) :: fen,fen_sq,den1,den2,perm_real1,perm_real2,perm_imag1,perm_imag2
  REAL( fp_kind ) :: tcelsius,tcelsius_sq,tcelsius_cu,f1,f2,del1,del2,einf
  REAL( fp_kind ) :: perm_free,sigma,perm_imag3,perm_Real,perm_imag

  REAL( fp_kind ) :: tcelsius_tl,tcelsius_sq_tl,tcelsius_cu_tl
  REAL( fp_kind ) :: f1_tl,f2_tl
  REAL( fp_kind ) :: del1_tl,del2_tl,einf_tl
  REAL( fp_kind ) :: den1_tl,den2_tl,perm_real1_tl,perm_real2_tl
  REAL( fp_kind ) :: perm_imag1_tl,perm_imag2_tl,sigma_tl,perm_imag3_tl
  REAL(fp_kind) :: perm_Real_tl,perm_imag_tl

    !-----------------------------------------------------
    !1.2 calculate permittivity using double-debye formula
    !-----------------------------------------------------
    !Set values for temperature polynomials (convert from kelvin to celsius)
    tcelsius = SST - 273.15_fp_kind
    tcelsius_sq = tcelsius * tcelsius     !quadratic
    tcelsius_cu = tcelsius_sq * tcelsius  !cubic
    tcelsius_tl = SST_tl
    tcelsius_sq_tl = 2.0_fp_kind * tcelsius * tcelsius_tl
    tcelsius_cu_tl = 3.0_fp_kind * tcelsius_sq * tcelsius_tl

    !Define two relaxation frequencies, f1 and f2
    f1 = 17.5350_fp_kind - 0.617670_fp_kind * tcelsius + 0.00894800_fp_kind * tcelsius_sq
    f2 = 3.18420_fp_kind + 0.0191890_fp_kind * tcelsius - 0.0108730_fp_kind * tcelsius_sq + 0.000258180_fp_kind * tcelsius_cu
    f1_tl = - 0.617670_fp_kind * tcelsius_tl + 0.00894800_fp_kind * tcelsius_sq_tl
    f2_tl =  0.0191890_fp_kind * tcelsius_tl - 0.0108730_fp_kind * tcelsius_sq_tl + 0.000258180_fp_kind * tcelsius_cu_tl

    !Static permittivity estatic = del1+del2+einf
    del1 = 68.3960_fp_kind -0.406430_fp_kind * tcelsius + 0.0228320_fp_kind * tcelsius_sq - 0.000530610_fp_kind * tcelsius_cu
    del2 = 4.76290_fp_kind + 0.154100_fp_kind * tcelsius -0.0337170_fp_kind * tcelsius_sq + 0.000844280_fp_kind * tcelsius_cu
    einf = 5.31250_fp_kind - 0.0114770_fp_kind * tcelsius
    del1_tl = -0.406430_fp_kind * tcelsius_tl + 0.0228320_fp_kind * tcelsius_sq_tl - 0.000530610_fp_kind * tcelsius_cu_tl
    del2_tl =  0.154100_fp_kind * tcelsius_tl -0.0337170_fp_kind * tcelsius_sq_tl + 0.000844280_fp_kind * tcelsius_cu_tl
    einf_tl = -0.0114770_fp_kind * tcelsius_tl


    fen          = 2.0_fp_kind * PI * f * 0.001_fp_kind
    fen_sq       = fen*fen
    den1         = 1.0_fp_kind + fen_sq * f1 * f1
    den2         = 1.0_fp_kind + fen_sq * f2 * f2
    perm_real1   = del1 / den1
    perm_real2   = del2 / den2
    perm_imag1   = del1 * fen * f1 / den1
    perm_imag2   = del2 * fen * f2 / den2
    ! perm_free = 8.854E-3_fp_kind not 8.854E-12 as multiplied by 1E9 for GHz
    perm_free    = 8.854E-3_fp_kind
    sigma        = 2.906_fp_kind + 0.09437_fp_kind * tcelsius
    perm_imag3   = sigma / (2.0_fp_kind * PI * perm_free * f)
    perm_Real    = perm_real1 + perm_real2 + einf
    perm_imag    = perm_imag1 + perm_imag2 + perm_imag3
    eps_ocean = cmplx(perm_Real,perm_imag,fp_kind)


    den1_tl         = 2.0_fp_kind * fen_sq * f1 * f1_tl
    den2_tl         = 2.0_fp_kind * fen_sq * f2 * f2_tl
    perm_real1_tl   = (den1 * del1_tl - del1 * den1_tl) / (den1 * den1)
    perm_real2_tl   = (den2 * del2_tl - del2 * den2_tl) / (den2 * den2)
    perm_imag1_tl   = fen * ( den1 * ( del1_tl * f1 + del1 * f1_tl)&
                    & - (del1 * f1 * den1_tl) )  / (den1 * den1)
    perm_imag2_tl   = fen * ( den2 * ( del2_tl * f2 + del2 * f2_tl)&
                    & - (del2 * f2 * den2_tl) )  / (den2 * den2)
    sigma_tl        = 0.09437_fp_kind * tcelsius_tl
    perm_imag3_tl   = sigma_tl / (2.0_fp_kind * PI * perm_free * f)
    perm_Real_tl    = perm_real1_tl + perm_real2_tl + einf_tl
    perm_imag_tl    = perm_imag1_tl + perm_imag2_tl + perm_imag3_tl
    eps_ocean_tl = cmplx(perm_Real_tl,perm_imag_tl,fp_kind)

  RETURN

 END SUBROUTINE Compute_Ellison_eps_ocean_TL
!
!
!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       Compute_Ellison_eps_ocean_AD
!
! PURPOSE:
!       Subroutine to compute ocean permittivity adjoint
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL Compute_Ellison_eps_ocean_AD
!
! INPUT ARGUMENTS:
!
!         SST                      Sea Surface Temperature
!                                  UNITS:      Kelvin
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         S                        Salinity
!                                  UNITS:      parts per thousand
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         f                        Frequency
!                                  UNITS:      GHz
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         eps_ocean_ad             Ocean permittivity tangent liner
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
! OUTPUT ARGUMENTS:
! 
!         SST_ad                   Sea Surface Temperature adjoint
!                                  UNITS:      Kelvin
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         eps_ocean                Ocean permittivity
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
! Reference:
!
!  Ellison, W. J. et al. (2003) A comparison of ocean emissivity models using the Advanced Microwave Sounding Unit,
!                               the Special Sensor Microwave Imager, the TRMM Microwave Imager, and 
!                               airborne radiometer observations. Journal of Geophysical Research, 108, 4663
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
SUBROUTINE Compute_Ellison_eps_ocean_AD(SST, & ! Input, Water temperature in Kelvin
                                        SST_ad, & 
                                        S, & ! Input, Salinity in parts per thousand
                                        f, & ! Input, Frequency in GHz
                                        eps_ocean, & ! Output, permitivity
                                        eps_ocean_ad)
!------------------------------------------------------------------------------------------------------------
  USE Type_Kinds
  IMPLICIT NONE
  REAL( fp_kind ), INTENT( IN ) :: SST, S, F
  COMPLEX( fp_kind ), INTENT( OUT ) :: eps_ocean
  REAL( fp_kind ), INTENT( IN OUT ) :: SST_ad
  COMPLEX( fp_kind ), INTENT( IN ) :: eps_ocean_ad

  REAL( fp_kind ) :: t,t2,eswi,eo,eswo,a,b,d,esw,tswo,tsw,sswo,fi,ssw,eps_imag,eps_real
  REAL( fp_kind ) :: fen,fen_sq,den1,den2,perm_real1,perm_real2,perm_imag1,perm_imag2
  REAL( fp_kind ) :: tcelsius,tcelsius_sq,tcelsius_cu,f1,f2,del1,del2,einf
  REAL( fp_kind ) :: perm_free,sigma,perm_imag3,perm_Real,perm_imag

  REAL( fp_kind ) :: tcelsius_ad,tcelsius_sq_ad,tcelsius_cu_ad
  REAL( fp_kind ) :: f1_ad,f2_ad
  REAL( fp_kind ) :: del1_ad,del2_ad,einf_ad
  REAL( fp_kind ) :: den1_ad,den2_ad,perm_real1_ad,perm_real2_ad
  REAL( fp_kind ) :: perm_imag1_ad,perm_imag2_ad,sigma_ad,perm_imag3_ad
  REAL( fp_kind ) :: perm_Real_ad,perm_imag_ad

! Initialize
     tcelsius_ad = 0.0_fp_kind
     tcelsius_sq_ad = 0.0_fp_kind
     tcelsius_cu_ad = 0.0_fp_kind
     f1_ad = 0.0_fp_kind
     f2_ad = 0.0_fp_kind
     del1_ad = 0.0_fp_kind
     del2_ad = 0.0_fp_kind
     einf_ad = 0.0_fp_kind
     den1_ad = 0.0_fp_kind
     den2_ad = 0.0_fp_kind
     perm_real1_ad = 0.0_fp_kind
     perm_real2_ad = 0.0_fp_kind
     perm_imag1_ad = 0.0_fp_kind
     perm_imag2_ad = 0.0_fp_kind
     sigma_ad = 0.0_fp_kind
     perm_imag3_ad = 0.0_fp_kind
     perm_Real_ad = 0.0_fp_kind
     perm_imag_ad = 0.0_fp_kind

!----------- forward

    !-----------------------------------------------------
    !1.2 calculate permittivity using double-debye formula
    !-----------------------------------------------------
    !Set values for temperature polynomials (convert from kelvin to celsius)
    tcelsius = SST - 273.15_fp_kind
    tcelsius_sq = tcelsius * tcelsius     !quadratic
    tcelsius_cu = tcelsius_sq * tcelsius  !cubic

    !Define two relaxation frequencies, f1 and f2
    f1 = 17.5350_fp_kind -0.617670_fp_kind * tcelsius + 0.00894800_fp_kind * tcelsius_sq
    f2 = 3.18420_fp_kind + 0.0191890_fp_kind * tcelsius -0.0108730_fp_kind * tcelsius_sq + 0.000258180_fp_kind * tcelsius_cu

    !Static permittivity estatic = del1+del2+einf
    del1 = 68.3960_fp_kind - 0.406430_fp_kind * tcelsius + 0.0228320_fp_kind * tcelsius_sq -0.000530610_fp_kind * tcelsius_cu
    del2 = 4.76290_fp_kind + 0.154100_fp_kind * tcelsius -0.0337170_fp_kind * tcelsius_sq + 0.000844280_fp_kind * tcelsius_cu
    einf = 5.31250_fp_kind - 0.0114770_fp_kind * tcelsius
    fen          = 2.0_fp_kind * PI * f * 0.001_fp_kind
    fen_sq       = fen*fen
    den1         = 1.0_fp_kind + fen_sq * f1 * f1
    den2         = 1.0_fp_kind + fen_sq * f2 * f2
    perm_real1   = del1 / den1
    perm_real2   = del2 / den2
    perm_imag1   = del1 * fen * f1 / den1
    perm_imag2   = del2 * fen * f2 / den2
    ! perm_free = 8.854E-3_fp_kind not 8.854E-12 as multiplied by 1E9 for GHz
    perm_free    = 8.854E-3_fp_kind
    sigma        = 2.906_fp_kind + 0.09437_fp_kind * tcelsius
    perm_imag3   = sigma / (2.0_fp_kind * PI * perm_free * f)
    perm_Real    = perm_real1 + perm_real2 + einf
    perm_imag    = perm_imag1 + perm_imag2 + perm_imag3
    eps_ocean = cmplx(perm_Real,perm_imag,fp_kind)


!----------- adjoint

        perm_Real_ad =  real( eps_ocean_ad )
        perm_imag_ad =  -aimag( eps_ocean_ad )

        perm_imag1_ad = perm_imag_ad
        perm_imag2_ad = perm_imag_ad
        perm_imag3_ad = perm_imag_ad

        einf_ad       = perm_real_ad
        perm_real1_ad = perm_real_ad
        perm_real2_ad = perm_real_ad

        sigma_ad = perm_imag3_ad / (2.0_fp_kind * PI * perm_free * f)
        tcelsius_ad = 0.09437_fp_kind * sigma_ad

        del2_ad =  perm_imag2_ad * fen * den2 * f2  / (den2 * den2)
        den2_ad = -perm_imag2_ad * fen * del2 * f2  / (den2 * den2)
        f2_ad   =  perm_imag2_ad * fen * den2 * del2/ (den2 * den2)

        del1_ad =  perm_imag1_ad * fen * den1 * f1  / (den1 * den1)
        den1_ad = -perm_imag1_ad * fen * del1 * f1  / (den1 * den1)
        f1_ad   =  perm_imag1_ad * fen * den1 * del1/ (den1 * den1)


        del2_ad = del2_ad + perm_real2_ad * den2 / (den2 * den2)
        den2_ad = den2_ad - perm_real2_ad * del2 / (den2 * den2)

        del1_ad = del1_ad + perm_real1_ad * den1 / (den1 * den1)
        den1_ad = den1_ad - perm_real1_ad * del1 / (den1 * den1)


        f2_ad = f2_ad + den2_ad * 2 * fen_sq * f2
        f1_ad = f1_ad + den1_ad * 2 * fen_sq * f1

        !Static permittivity estatic = del1+del2+einf
        tcelsius_ad    = tcelsius_ad - 0.0114770_fp_kind * einf_ad
        tcelsius_ad    = tcelsius_ad + del2_ad * 0.154100_fp_kind
        tcelsius_sq_ad = del2_ad * ( -0.0337170_fp_kind )
        tcelsius_cu_ad = del2_ad * 0.000844280_fp_kind

        tcelsius_ad    = tcelsius_ad    + del1_ad * (-0.406430_fp_kind)
        tcelsius_sq_ad = tcelsius_sq_ad + del1_ad * 0.0228320_fp_kind
        tcelsius_cu_ad = tcelsius_cu_ad + del1_ad * (-0.000530610_fp_kind)


        !Define two relaxation frequencies, f1 and f2
        tcelsius_ad    = tcelsius_ad    + f2_ad * 0.0191890_fp_kind
        tcelsius_sq_ad = tcelsius_sq_ad + f2_ad * (-0.0108730_fp_kind)
        tcelsius_cu_ad = tcelsius_cu_ad + f2_ad * (0.000258180_fp_kind)

        tcelsius_ad    = tcelsius_ad    + f1_ad * ( -0.617670_fp_kind)
        tcelsius_sq_ad = tcelsius_sq_ad + f1_ad * (0.00894800_fp_kind)


        !Set values for temperature polynomials (convert from kelvin to celsius)
        tcelsius_ad    = tcelsius_ad + tcelsius_cu_ad * 3.0_fp_kind * tcelsius_sq

        tcelsius_ad    = tcelsius_ad + tcelsius_sq_ad * 2.0_fp_kind * tcelsius
        sst_ad = sst_ad + tcelsius_ad


  RETURN

END SUBROUTINE Compute_Ellison_eps_ocean_AD
!
!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       Compute_Guillou_eps_ocean
!
! PURPOSE:
!       Subroutine to compute ocean permittivity
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL Compute_Guillou_eps_ocean
!
! INPUT ARGUMENTS:
!
!         SST                      Sea Surface Temperature
!                                  UNITS:      Kelvin
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         S                        Salinity
!                                  UNITS:      parts per thousand
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         f                        Frequency
!                                  UNITS:      GHz
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!
! OUTPUT ARGUMENTS:
! 
!         eps_ocean                Ocean permittivity
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
! Reference:
!   
!  Guillou, C. et al. (1998) Impact of new permittivity measurements on sea surface emissivity modeling in 
!                            microwaves. Radio Science, Volume 33, Number 3, Pages 649-667
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
  SUBROUTINE Compute_Guillou_eps_ocean(SST,     & ! Input, Water temperature in Kelvin
                                       S,       & ! Input, Salinity in parts per thousand
                                       f,       & ! Input, Frequency in GHz
                                       eps_ocean) ! Output, permitivity
!------------------------------------------------------------------------------------------------------------
  USE Type_Kinds
  IMPLICIT NONE
  REAL( fp_kind ), INTENT( IN ) :: SST, S, F
  COMPLEX( fp_kind ), INTENT( OUT ) :: eps_ocean

  ! internal variables
  REAL( fp_kind ) tcelsius,tcelsius_sq,tcelsius_cu,tcelsius4,tcelsius5
  REAL(fp_kind) c1,c2,sigma,a1,a2,b1,b2,tau,eps0
  REAL(fp_kind) eps_real,eps_imag,mu,epss,epsinf
  REAL(fp_kind)mu_sq,tau_sq

  tcelsius = SST - 273.16_fp_kind
  tcelsius_sq = tcelsius * tcelsius     !quadratic
  tcelsius_cu = tcelsius_sq * tcelsius  !cubic
  tcelsius4  = tcelsius_sq * tcelsius_sq  !4
  tcelsius5  = tcelsius_sq * tcelsius_cu  !5
  mu = f * 1.0E09_fp_kind   ! Herz
  mu_sq = mu*mu
  epss= 8.8419E-12_fp_kind

  c1 = 0.086374_fp_kind + 0.030606_fp_kind*tcelsius - 0.0004121_fp_kind*tcelsius_sq
  c2 = 0.077454_fp_kind + 0.001687_fp_kind*tcelsius + 0.00001937_fp_kind*tcelsius_sq
  sigma = c1 + c2 * S

  epsinf = 6.4587_fp_kind - 0.04203_fp_kind*tcelsius - 0.0065881_fp_kind*tcelsius_sq &
         + 0.00064924_fp_kind*tcelsius_cu - 1.2328E-05_fp_kind*tcelsius4 + 5.0433E-08_fp_kind *tcelsius5

  a1 = 81.820_fp_kind - 6.0503E-02_fp_kind*tcelsius - 3.1661E-02_fp_kind*tcelsius_sq  &
     + 3.1097E-03_fp_kind*tcelsius_cu - 1.1791E-04_fp_kind*tcelsius4 + 1.4838E-06_fp_kind*tcelsius5

  a2 = 0.12544_fp_kind + 9.4037E-03_fp_kind*tcelsius - 9.5551E-04_fp_kind*tcelsius_sq &
     + 9.0888E-05_fp_kind*tcelsius_cu - 3.6011E-06_fp_kind*tcelsius4 + 4.7130E-08_fp_kind*tcelsius5

  b1 = 17.303_fp_kind - 0.66651_fp_kind*tcelsius + 5.1482E-03_fp_kind*tcelsius_sq + 1.2145E-03_fp_kind*tcelsius_cu &
     -5.0325E-05_fp_kind*tcelsius4 + 5.8272E-07_fp_kind*tcelsius5

  b2 = -6.272E-03_fp_kind + 2.357E-04_fp_kind*tcelsius + 5.075E-04_fp_kind*tcelsius_sq - 6.3983E-05_fp_kind*tcelsius_cu &
     + 2.463E-06_fp_kind*tcelsius4 - 3.0676E-08_fp_kind*tcelsius5

  tau = (b1 + S*b2 ) * 1.0E-12_fp_kind
  tau_sq = tau*tau
  eps0 = a1 - S*a2

  eps_real = epsinf + (eps0 - epsinf)/(1.0_fp_kind + 4.0_fp_kind * PI*PI*mu_sq*tau_sq)

  eps_imag = ( (eps0 - epsinf)*2.0_fp_kind*PI*mu*tau)/(1.0_fp_kind+4.0_fp_kind*PI*PI*mu_sq*tau_sq) + &
             sigma/(2.0_fp_kind*PI*epss*mu)
  eps_ocean = cmplx(eps_real,eps_imag,fp_kind)


  RETURN
 END SUBROUTINE Compute_Guillou_eps_ocean
!
!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       Compute_Guillou_eps_ocean_TL
!
! PURPOSE:
!       Subroutine to compute ocean permittivity tangent liner
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL Compute_Guillou_eps_ocean_TL
!
! INPUT ARGUMENTS:
!
!         SST                      Sea Surface Temperature
!                                  UNITS:      Kelvin
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         SST_tl                   Sea Surface Temperature tangent liner
!                                  UNITS:      Kelvin
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         S                        Salinity
!                                  UNITS:      parts per thousand
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         f                        Frequency
!                                  UNITS:      GHz
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
! OUTPUT ARGUMENTS:
! 
!         eps_ocean                Ocean permittivity
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
!         eps_ocean_tl             Ocean permittivity tangent liner
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
! Reference:
!   
!  Guillou, C. et al. (1998) Impact of new permittivity measurements on sea surface emissivity modeling in 
!                            microwaves. Radio Science, Volume 33, Number 3, Pages 649-667
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
  SUBROUTINE Compute_Guillou_eps_ocean_TL(SST, & ! Input, Water temperature in Kelvin
                                          SST_tl, &
                                          S, & ! Input, Salinity in parts per thousand
                                          f, & ! Input, Frequency in GHz
                                          eps_ocean, & ! Output, permitivity
                                          eps_ocean_tl) ! Output
!------------------------------------------------------------------------------------------------------------
  USE Type_Kinds
  IMPLICIT NONE
  REAL( fp_kind ), INTENT( IN ) :: SST, SST_tl, S, F
  COMPLEX( fp_kind ), INTENT( OUT ) :: eps_ocean,eps_ocean_tl

  ! internal variables
  REAL(fp_kind) tcelsius,tcelsius_sq,tcelsius_cu,tcelsius4,tcelsius5,tcelsius_tl
  REAL(fp_kind) c1,c2,sigma,a1,a2,b1,b2,tau,eps0
  REAL(fp_kind) eps_real,eps_imag,mu,epss,epsinf
  REAL(fp_kind) c1_tl,c2_tl,sigma_tl,a1_tl,a2_tl,b1_tl,b2_tl,tau_tl,eps0_tl
  REAL(fp_kind) eps_real_tl,eps_imag_tl,epsinf_tl
  REAL(fp_kind) mu_sq,tau_sq

  tcelsius = SST - 273.16_fp_kind
  tcelsius_sq = tcelsius * tcelsius     !quadratic
  tcelsius_cu = tcelsius_sq * tcelsius  !cubic
  tcelsius4  = tcelsius_sq * tcelsius_sq  !4
  tcelsius5  = tcelsius_sq * tcelsius_cu  !5
  tcelsius_tl = SST_tl
  mu = f * 1.0E09_fp_kind   ! Herz
  mu_sq = mu*mu
  epss= 8.8419E-12_fp_kind

  c1 = 0.086374_fp_kind + 0.030606_fp_kind*tcelsius - 0.0004121_fp_kind*tcelsius_sq
  c1_tl =  + 0.030606_fp_kind*tcelsius_tl - 2.0_fp_kind*0.0004121_fp_kind*tcelsius*tcelsius_tl
  c2 = 0.077454_fp_kind + 0.001687_fp_kind*tcelsius + 0.00001937_fp_kind*tcelsius_sq
  c2_tl =  + 0.001687_fp_kind*tcelsius_tl + 2.0_fp_kind*0.00001937_fp_kind*tcelsius*tcelsius_tl
  sigma = c1 + c2 * S
  sigma_tl = c1_tl + c2_tl * S

  epsinf = 6.4587_fp_kind &
         - 0.04203_fp_kind*tcelsius &
         - 0.0065881_fp_kind*tcelsius_sq &
         + 0.00064924_fp_kind*tcelsius_cu &
         - 1.2328E-05_fp_kind*tcelsius4 &
         + 5.0433E-08_fp_kind*tcelsius5

  epsinf_tl = - 0.04203_fp_kind*tcelsius_tl &
              - 2.0_fp_kind*0.0065881_fp_kind*tcelsius*tcelsius_tl &
              + 3.0_fp_kind*0.00064924_fp_kind*tcelsius_sq*tcelsius_tl &
              - 4.0_fp_kind*1.2328E-05_fp_kind*tcelsius_cu*tcelsius_tl &
              + 5.0_fp_kind*5.0433E-08_fp_kind*tcelsius4*tcelsius_tl

  a1 = 81.820_fp_kind &
      - 6.0503E-02_fp_kind*tcelsius &
      - 3.1661E-02_fp_kind*tcelsius_sq &
      + 3.1097E-03_fp_kind*tcelsius_cu &
      - 1.1791E-04_fp_kind*tcelsius4 &
      + 1.4838E-06_fp_kind*tcelsius5

  a1_tl = - 6.0503E-02_fp_kind*tcelsius_tl &
          - 2.0_fp_kind*3.1661E-02_fp_kind*tcelsius*tcelsius_tl  &
          + 3.0_fp_kind*3.1097E-03_fp_kind*tcelsius_sq*tcelsius_tl &
          - 4.0_fp_kind*1.1791E-04_fp_kind*tcelsius_cu*tcelsius_tl &
          + 5.0_fp_kind*1.4838E-06_fp_kind*tcelsius4*tcelsius_tl

  a2 = 0.12544_fp_kind &
     + 9.4037E-03_fp_kind*tcelsius &
     - 9.5551E-04_fp_kind*tcelsius_sq &
     + 9.0888E-05_fp_kind*tcelsius_cu &
     - 3.6011E-06_fp_kind*tcelsius4 &
     + 4.7130E-08_fp_kind*tcelsius5

  a2_tl = + 9.4037E-03_fp_kind*tcelsius_tl &
          - 2.0_fp_kind*9.5551E-04_fp_kind*tcelsius*tcelsius_tl &
          + 3.0_fp_kind*9.0888E-05_fp_kind*tcelsius_sq*tcelsius_tl &
          - 4.0_fp_kind*3.6011E-06_fp_kind*tcelsius_cu*tcelsius_tl &
          + 5.0_fp_kind*4.7130E-08_fp_kind*tcelsius4*tcelsius_tl

  b1 = 17.303_fp_kind &
      - 0.66651_fp_kind*tcelsius &
      + 5.1482E-03_fp_kind*tcelsius_sq &
      + 1.2145E-03_fp_kind*tcelsius_cu &
      - 5.0325E-05_fp_kind*tcelsius4 &
      + 5.8272E-07_fp_kind*tcelsius5

  b1_tl = - 0.66651_fp_kind*tcelsius_tl &
          + 2.0_fp_kind*5.1482E-03_fp_kind*tcelsius*tcelsius_tl &
          + 3.0_fp_kind*1.2145E-03_fp_kind*tcelsius_sq*tcelsius_tl &
          - 4.0_fp_kind*5.0325E-05_fp_kind*tcelsius_cu*tcelsius_tl &
          + 5.0_fp_kind*5.8272E-07_fp_kind*tcelsius4*tcelsius_tl

  b2 = -6.272E-03_fp_kind &
      + 2.357E-04_fp_kind*tcelsius &
      + 5.075E-04_fp_kind*tcelsius_sq &
      - 6.3983E-05_fp_kind*tcelsius_cu &
      + 2.463E-06_fp_kind*tcelsius4 &
      - 3.0676E-08_fp_kind*tcelsius5

  b2_tl = + 2.357E-04_fp_kind*tcelsius_tl &
          + 2.0_fp_kind*5.075E-04_fp_kind*tcelsius*tcelsius_tl &
          - 3.0_fp_kind*6.3983E-05_fp_kind*tcelsius_sq*tcelsius_tl &
          + 4.0_fp_kind*2.463E-06_fp_kind*tcelsius_cu*tcelsius_tl &
          - 5.0_fp_kind*3.0676E-08_fp_kind*tcelsius4*tcelsius_tl

  tau = (b1 + S*b2 ) * 1.0E-12_fp_kind
  tau_sq = tau*tau
  tau_tl = (b1_tl + S*b2_tl ) * 1.0E-12_fp_kind
  eps0 = a1 - S*a2
  eps0_tl = a1_tl - S*a2_tl

  eps_real = epsinf + (eps0 - epsinf)/(1.0_fp_kind + 4.0_fp_kind * PI*PI*mu_sq*tau_sq)
  eps_real_tl = epsinf_tl + (eps0_tl - epsinf_tl)/(1.0_fp_kind + 4.0_fp_kind * PI*PI*mu_sq*tau_sq)  &
   - (eps0 - epsinf)/(1.0_fp_kind + 4.0_fp_kind * PI*PI*mu_sq*tau_sq)**2 * 2.0_fp_kind*4.0_fp_kind * PI*PI*mu_sq*tau*tau_tl

  eps_imag = ((eps0 - epsinf)*2.0_fp_kind*PI*mu*tau)/(1.0_fp_kind+4.0_fp_kind*PI*PI*mu_sq*tau_sq) + &
             sigma/(2.0_fp_kind*PI*epss*mu)

  eps_imag_tl = ((eps0_tl - epsinf_tl)*2.0_fp_kind*PI*mu*tau)/(1.0_fp_kind+4.0_fp_kind*PI*PI*mu_sq*tau_sq) + &
                ((eps0 - epsinf)*2.0_fp_kind*PI*mu*tau_tl)/(1.0_fp_kind+4.0_fp_kind*PI*PI*mu_sq*tau_sq)  &
              - 2.0_fp_kind*4.0_fp_kind*PI*PI*mu_sq*tau*tau_tl &
              *((eps0 - epsinf)*2.0_fp_kind*PI*mu*tau) &
              /(1.0_fp_kind+4.0_fp_kind*PI*PI*mu*mu*tau*tau)**2 &
              + sigma_tl/(2.0_fp_kind*PI*epss*mu)

  eps_ocean = cmplx(eps_real,eps_imag,fp_kind)
  eps_ocean_tl = cmplx(eps_real_tl,eps_imag_tl,fp_kind)

  RETURN

 END SUBROUTINE Compute_Guillou_eps_ocean_TL


!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       Compute_Guillou_eps_ocean_AD
!
! PURPOSE:
!       Subroutine to compute ocean permittivity adjoint
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL Compute_Guillou_eps_ocean_AD
!
! INPUT ARGUMENTS:
!
!         SST                      Sea Surface Temperature
!                                  UNITS:      Kelvin
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         S                        Salinity
!                                  UNITS:      parts per thousand
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         f                        Frequency
!                                  UNITS:      GHz
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         eps_ocean_ad             Ocean permittivity tangent liner
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
! OUTPUT ARGUMENTS:
! 
!         SST_ad                   Sea Surface Temperature adjoint
!                                  UNITS:      Kelvin
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         eps_ocean                Ocean permittivity
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
! Reference:
!   
!  Guillou, C. et al. (1998) Impact of new permittivity measurements on sea surface emissivity modeling in 
!                            microwaves. Radio Science, Volume 33, Number 3, Pages 649-667
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
  SUBROUTINE Compute_Guillou_eps_ocean_AD(SST, & ! Input, Water temperature in Kelvin
                                          SST_ad, &
                                          S, & ! Input, Salinity in parts per thousand
                                          f, & ! Input, Frequency in GHz
                                          eps_ocean, & ! Output, permitivity
                                          eps_ocean_ad) 
!------------------------------------------------------------------------------------------------------------
  USE Type_Kinds
  IMPLICIT NONE
  REAL( fp_kind ), INTENT( IN ) :: SST, S, F
  REAL( fp_kind ), INTENT( IN OUT ) :: SST_ad
  COMPLEX( fp_kind ), INTENT( OUT ) :: eps_ocean
  COMPLEX( fp_kind ), INTENT( IN ) :: eps_ocean_ad

  ! internal variables
  REAL(fp_kind) tcelsius,tcelsius_sq,tcelsius_cu,tcelsius4,tcelsius5
  REAL(fp_kind) c1,c2,sigma,a1,a2,b1,b2,tau,eps0
  REAL(fp_kind) eps_real,eps_imag,mu,epss,epsinf
  REAL(fp_kind) tcelsius_ad,c1_ad,c2_ad,sigma_ad,a1_ad,a2_ad,b1_ad,b2_ad,tau_ad,eps0_ad
  REAL(fp_kind) eps_real_ad,eps_imag_ad,epsinf_ad
  REAL(fp_kind) mu_sq,tau_sq
!
! Initialize
 tcelsius_ad = 0.0
 c1_ad = 0.0_fp_kind
 c2_ad = 0.0_fp_kind
 sigma_ad = 0.0_fp_kind
 a1_ad = 0.0_fp_kind
 a2_ad = 0.0_fp_kind
 b1_ad = 0.0_fp_kind
 b2_ad = 0.0_fp_kind
 tau_ad = 0.0_fp_kind
 eps0_ad = 0.0_fp_kind
 eps_real_ad = 0.0_fp_kind
 eps_imag_ad = 0.0_fp_kind
 epsinf_ad = 0.0_fp_kind


!  Forward
  tcelsius = SST - 273.16_fp_kind
  tcelsius_sq = tcelsius * tcelsius     !quadratic
  tcelsius_cu = tcelsius_sq * tcelsius  !cubic
  tcelsius4 = tcelsius_sq * tcelsius_sq  !4
  tcelsius5 = tcelsius_sq * tcelsius_cu  !5
  mu = f * 1.0E09_fp_kind   ! Herz
  mu_sq = mu*mu
  epss= 8.8419E-12_fp_kind

  c1 = 0.086374_fp_kind + 0.030606_fp_kind*tcelsius - 0.0004121_fp_kind*tcelsius_sq
  c2 = 0.077454_fp_kind + 0.001687_fp_kind*tcelsius + 0.00001937_fp_kind*tcelsius_sq
  sigma = c1 + c2 * S

  epsinf = 6.4587_fp_kind - 0.04203_fp_kind*tcelsius - 0.0065881_fp_kind*tcelsius_sq &
         + 0.00064924_fp_kind*tcelsius_cu - 1.2328E-05_fp_kind*tcelsius4 + 5.0433E-08_fp_kind *tcelsius5

  a1 = 81.820_fp_kind - 6.0503E-02_fp_kind*tcelsius - 3.1661E-02_fp_kind*tcelsius_sq  &
     + 3.1097E-03_fp_kind*tcelsius_cu - 1.1791E-04_fp_kind*tcelsius4 + 1.4838E-06_fp_kind*tcelsius5

  a2 = 0.12544_fp_kind + 9.4037E-03_fp_kind*tcelsius - 9.5551E-04_fp_kind*tcelsius_sq &
     + 9.0888E-05_fp_kind*tcelsius_cu - 3.6011E-06_fp_kind*tcelsius4 + 4.7130E-08_fp_kind*tcelsius5

  b1 = 17.303_fp_kind - 0.66651_fp_kind*tcelsius + 5.1482E-03_fp_kind*tcelsius_sq + 1.2145E-03_fp_kind*tcelsius_cu &
     -5.0325E-05_fp_kind*tcelsius4 + 5.8272E-07_fp_kind*tcelsius5

  b2 = -6.272E-03_fp_kind + 2.357E-04_fp_kind*tcelsius + 5.075E-04_fp_kind*tcelsius_sq - 6.3983E-05_fp_kind*tcelsius_cu &
     + 2.463E-06_fp_kind*tcelsius4 - 3.0676E-08_fp_kind*tcelsius5

  tau = (b1 + S*b2 ) * 1.0E-12_fp_kind
  tau_sq = tau*tau
  eps0 = a1 - S*a2

  eps_real = epsinf + (eps0 - epsinf)/(1.0_fp_kind + 4.0_fp_kind * PI*PI*mu_sq*tau_sq)

  eps_imag = ( (eps0 - epsinf)*2.0_fp_kind*PI*mu*tau)/(1.0_fp_kind+4.0_fp_kind*PI*PI*mu_sq*tau_sq) + &
             sigma/(2.0_fp_kind*PI*epss*mu)
  eps_ocean = cmplx(eps_real,eps_imag,fp_kind)


!  Adjoint
  eps_real_ad = real(eps_ocean_ad)
  eps_imag_ad = -aimag(eps_ocean_ad)

  eps0_ad = (2.0_fp_kind*PI*mu*tau)/(1.0_fp_kind+4.0_fp_kind*PI*PI*mu_sq*tau_sq) * eps_imag_ad
  epsinf_ad = (-2.0_fp_kind*PI*mu*tau)/(1.0_fp_kind+4.0_fp_kind*PI*PI*mu_sq*tau_sq) *eps_imag_ad
  tau_ad = (((eps0 - epsinf)*2.0_fp_kind*PI*mu)/(1.0_fp_kind+4.0_fp_kind*PI*PI*mu_sq*tau_sq) &
           - 2.0_fp_kind*4.0_fp_kind*PI*PI*mu_sq*tau* &
           ((eps0 - epsinf)*2.0_fp_kind*PI*mu*tau)/(1.0_fp_kind+4.0_fp_kind*PI*PI*mu_sq*tau_sq)**2 )*eps_imag_ad
  sigma_ad = 1.0_fp_kind/(2.0_fp_kind*PI*epss*mu) * eps_imag_ad

  epsinf_ad = epsinf_ad + (1.0_fp_kind - 1.0_fp_kind/(1.0_fp_kind + 4.0_fp_kind * PI*PI*mu_sq*tau_sq) )*eps_real_ad
  eps0_ad = eps0_ad + 1.0_fp_kind/(1.0_fp_kind + 4.0_fp_kind * PI*PI*mu_sq*tau_sq)*eps_real_ad
  tau_ad = tau_ad - (eps0 - epsinf)/(1.0_fp_kind + 4.0_fp_kind * PI*PI*mu_sq*tau_sq)**2 &
           * 2.0_fp_kind*4.0_fp_kind * PI*PI*mu_sq*tau * eps_real_ad

  a1_ad = eps0_ad
  a2_ad = -S*eps0_ad

  b1_ad = tau_ad*1.0E-12_fp_kind
  b2_ad = tau_ad*S*1.0E-12_fp_kind

  tcelsius_ad = +( 2.357E-04_fp_kind + 2.0_fp_kind*5.075E-04_fp_kind*tcelsius - 3.0_fp_kind*6.3983E-05_fp_kind*tcelsius_sq &
         + 4.0_fp_kind*2.463E-06_fp_kind*tcelsius_cu - 5.0_fp_kind*3.0676E-08_fp_kind*tcelsius4 ) * b2_ad

  tcelsius_ad = tcelsius_ad + (-0.66651_fp_kind + 2.0_fp_kind*5.1482E-03_fp_kind*tcelsius &
                + 3.0_fp_kind*1.2145E-03_fp_kind*tcelsius_sq &
                 -4.0_fp_kind*5.0325E-05_fp_kind*tcelsius_cu + 5.0_fp_kind*5.8272E-07_fp_kind*tcelsius4 ) * b1_ad

  tcelsius_ad = tcelsius_ad + (9.4037E-03_fp_kind - 2.0_fp_kind*9.5551E-04_fp_kind*tcelsius &
          + 3.0_fp_kind*9.0888E-05_fp_kind*tcelsius_sq - 4.0_fp_kind*3.6011E-06_fp_kind*tcelsius_cu &
          + 5.0_fp_kind*4.7130E-08_fp_kind*tcelsius4 )*a2_ad

  tcelsius_ad = tcelsius_ad + (-6.0503E-02_fp_kind - 2.0_fp_kind*3.1661E-02_fp_kind*tcelsius &
          + 3.0_fp_kind*3.1097E-03_fp_kind*tcelsius_sq - 4.0_fp_kind*1.1791E-04_fp_kind*tcelsius_cu &
          + 5.0_fp_kind*1.4838E-06_fp_kind*tcelsius4 )*a1_ad

  tcelsius_ad = tcelsius_ad + (-0.04203_fp_kind - 2.0_fp_kind*0.0065881_fp_kind*tcelsius &
          + 3.0_fp_kind*0.00064924_fp_kind*tcelsius_sq - 4.0_fp_kind*1.2328E-05_fp_kind*tcelsius_cu &
          + 5.0_fp_kind*5.0433E-08_fp_kind*tcelsius4 )*epsinf_ad

  c1_ad = sigma_ad
  c2_ad = sigma_ad*S

  tcelsius_ad = tcelsius_ad + (+ 0.001687_fp_kind + 2.0_fp_kind*0.00001937_fp_kind*tcelsius)*c2_ad
  tcelsius_ad = tcelsius_ad + (+ 0.030606_fp_kind - 2.0_fp_kind*0.0004121_fp_kind*tcelsius)*c1_ad

  SST_ad = SST_ad + tcelsius_ad

  RETURN

 END SUBROUTINE Compute_Guillou_eps_ocean_AD
!
!
!
!
!
!
!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       FRESNEL
!
! PURPOSE:
!       Subroutine to compute Fresnel reflectivity
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL FRESNEL
!
! INPUT ARGUMENTS:
!
!         e                        Emissivity
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
!         csl                      Cosine of incidence angle
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
! OUTPUT ARGUMENTS:
! 
!         Rv_Fresnel               Reflectivity for Vertical polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Rh_Fresnel               Reflectivity for Horizontal polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
subroutine FRESNEL(e,csl,Rv_Fresnel,Rh_Fresnel)
!------------------------------------------------------------------------------------------------------------
use type_kinds
implicit none
  COMPLEX( fp_kind ),INTENT ( IN )  :: e
  REAL( fp_kind ),   INTENT ( IN )  :: csl
  REAL( fp_kind ),   INTENT ( OUT ) :: Rv_Fresnel,Rh_Fresnel
  REAL( fp_kind )                   :: real_Rvv,imag_Rvv,real_Rhh,imag_Rhh
  COMPLEX( fp_kind )                :: perm1,perm2,Rvv,Rhh

    perm1          = sqrt(e - 1.0_fp_kind+csl*csl)
    perm2          = e* csl
    Rhh           = (csl-perm1) / (csl+perm1)
    Rvv           = (perm2-perm1) / (perm2+perm1)

    real_Rvv = real(Rvv)
    imag_Rvv = aimag(Rvv)
    Rv_Fresnel = real_Rvv * real_Rvv + imag_Rvv * imag_Rvv

    real_Rhh = real(Rhh)
    imag_Rhh = aimag(Rhh)
    Rh_Fresnel = real_Rhh * real_Rhh + imag_Rhh * imag_Rhh

  return

end subroutine fresnel
!
!
!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       FRESNEL_TL
!
! PURPOSE:
!       Subroutine to compute Fresnel reflectivity tangent liner
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL FRESNEL_TL
!
! INPUT ARGUMENTS:
!
!         e                        Emissivity
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
!         e_tl                     Emissivity tangent liner
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
!         csl                      Cosine of incidence angle
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
! OUTPUT ARGUMENTS:
! 
!         Rv_Fresnel               Reflectivity for Vertical polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Rh_Fresnel               Reflectivity for Horizontal polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Rv_Fresnel_tl            Reflectivity tangent liner for Vertical polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Rh_Fresnel_tl            Reflectivity tangent liner for Horizontal polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
subroutine FRESNEL_TL(e,e_tl,csl,Rv_Fresnel,Rh_Fresnel,Rv_Fresnel_tl,Rh_Fresnel_tl)
!------------------------------------------------------------------------------------------------------------
use type_kinds
implicit none
  COMPLEX( fp_kind ),INTENT ( IN )  :: e
  COMPLEX( fp_kind ),INTENT ( IN )  :: e_tl
  REAL( fp_kind ),   INTENT ( IN )  :: csl
  REAL( fp_kind ),   INTENT ( OUT ) :: Rv_Fresnel,Rh_Fresnel
  REAL( fp_kind ),   INTENT ( OUT ) :: Rv_Fresnel_tl,Rh_Fresnel_tl
  REAL( fp_kind )                   :: real_Rvv,imag_Rvv,real_Rhh,imag_Rhh
  COMPLEX( fp_kind )                :: perm1,perm2,Rvv,Rhh

  REAL( fp_kind ) Rv_Fresnel_real_tl,Rh_Fresnel_real_tl
  REAL( fp_kind ) Rv_Fresnel_imag_tl,Rh_Fresnel_imag_tl
  COMPLEX( fp_kind ) perm1_tl,perm2_tl,Rvv_tl,Rhh_tl

    perm1          = sqrt(e - 1.0_fp_kind+csl*csl)
    perm1_tl       = 0.5_fp_kind * e_tl / perm1
    perm2          = e* csl
    perm2_tl          = e_tl * csl
    Rhh           = (csl-perm1) / (csl+perm1)
    Rhh_tl           = - 2.0_fp_kind * csl * perm1_tl / (csl+perm1)**2
    Rvv           = (perm2-perm1) / (perm2+perm1)
    Rvv_tl           = 2.0_fp_kind * (perm1 * perm2_tl - perm1_tl * perm2) / (perm2+perm1)**2

    real_Rvv = real(Rvv)
    imag_Rvv = aimag(Rvv)
    Rv_Fresnel = real_Rvv * real_Rvv + imag_Rvv * imag_Rvv

    real_Rhh = real(Rhh)
    imag_Rhh = aimag(Rhh)
    Rh_Fresnel = real_Rhh * real_Rhh + imag_Rhh * imag_Rhh


    Rv_Fresnel_real_tl = real(Rvv_tl)
    Rv_Fresnel_imag_tl = aimag(Rvv_tl)
    Rv_Fresnel_tl = 2.0_fp_kind * (real_Rvv * Rv_Fresnel_real_tl) + &
                    2.0_fp_kind * (imag_Rvv * Rv_Fresnel_imag_tl)

    Rh_Fresnel_real_tl = Real(Rhh_tl)
    Rh_Fresnel_imag_tl = aimag(Rhh_tl)
    Rh_Fresnel_tl = 2.0_fp_kind * (real_Rhh * Rh_Fresnel_real_tl) + &
                    2.0_fp_kind * (imag_Rhh * Rh_Fresnel_imag_tl)

  return

end subroutine fresnel_TL
!
!------------------------------------------------------------------------------------------------------------
!M+
! NAME:
!       FRESNEL_AD
!
! PURPOSE:
!       Subroutine to compute Fresnel reflectivity adjoint
!
! CATEGORY:
!       CRTM : Surface : MW OPEN OCEAN EM
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL FRESNEL_AD
!
! INPUT ARGUMENTS:
!
!         e                        Emissivity
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
!         csl                      Cosine of incidence angle
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Rv_Fresnel_ad            Reflectivity adjoint for Vertical polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Rh_Fresnel_ad            Reflectivity adjoint for Horizontal polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
! OUTPUT ARGUMENTS:
! 
!         Rv_Fresnel               Reflectivity for Vertical polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         Rh_Fresnel               Reflectivity for Horizontal polarization
!                                  UNITS:      N/A
!                                  TYPE:       REAL( fp_kind )
!                                  DIMENSION:  Scalar
!
!         e_ad                     Emissivity adjoint
!                                  UNITS:      N/A
!                                  TYPE:       COMPLEX( fp_kind )
!                                  DIMENSION:  Scalar
!
! CALLS:
!       None
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!------------------------------------------------------------------------------------------------------------
subroutine FRESNEL_AD(e,e_ad,csl,Rv_Fresnel,Rh_Fresnel,Rv_Fresnel_ad,Rh_Fresnel_ad)
!------------------------------------------------------------------------------------------------------------
use type_kinds
implicit none
  COMPLEX( fp_kind ),INTENT ( IN )  :: e
  COMPLEX( fp_kind ),INTENT ( IN OUT ) :: e_ad
  REAL( fp_kind ),   INTENT ( IN )  :: csl
  REAL( fp_kind ),   INTENT ( OUT ) :: Rv_Fresnel,Rh_Fresnel
  REAL( fp_kind ),   INTENT ( IN )  :: Rv_Fresnel_ad,Rh_Fresnel_ad
  REAL( fp_kind )                   :: real_Rvv,imag_Rvv,real_Rhh,imag_Rhh
  COMPLEX( fp_kind )                :: perm1,perm2,Rvv,Rhh

  REAL( fp_kind ) Rv_Fresnel_real_ad,Rh_Fresnel_real_ad
  REAL( fp_kind ) Rv_Fresnel_imag_ad,Rh_Fresnel_imag_ad
  COMPLEX( fp_kind ) perm1_ad,perm2_ad,Rvv_ad,Rhh_ad


! ---- forward

    perm1          = sqrt(e - 1.0_fp_kind+csl*csl)
    perm2          = e* csl
    Rhh           = (csl-perm1) / (csl+perm1)
    Rvv           = (perm2-perm1) / (perm2+perm1)

    real_Rvv = real(Rvv)
    imag_Rvv = aimag(Rvv)
    Rv_Fresnel = real_Rvv * real_Rvv + imag_Rvv * imag_Rvv

    real_Rhh = real(Rhh)
    imag_Rhh = aimag(Rhh)
    Rh_Fresnel = real_Rhh * real_Rhh + imag_Rhh * imag_Rhh

! ---- adjoint
    Rh_Fresnel_real_ad = Rh_Fresnel_ad * 2.0_fp_kind * real_Rhh
    Rh_Fresnel_imag_ad = Rh_Fresnel_ad * 2.0_fp_kind * imag_Rhh

    Rhh_ad = cmplx(Rh_Fresnel_real_ad,-Rh_Fresnel_imag_ad,fp_kind)

    Rv_Fresnel_real_ad = Rv_Fresnel_ad * 2.0_fp_kind * real_Rvv
    Rv_Fresnel_imag_ad = Rv_Fresnel_ad * 2.0_fp_kind * imag_Rvv

    Rvv_ad = cmplx(Rv_Fresnel_real_ad,-Rv_Fresnel_imag_ad,fp_kind)

    perm1_ad = - Rvv_ad * 2.0_fp_kind * perm2 / (perm2+perm1)**2
    perm2_ad =   Rvv_ad * 2.0_fp_kind * perm1 / (perm2+perm1)**2

    perm1_ad = perm1_ad - Rhh_ad * 2.0_fp_kind * csl / (csl+perm1)**2

    e_ad = e_ad + perm2_ad * csl

    e_ad =  e_ad + perm1_ad * 0.5_fp_kind / perm1

  return

end subroutine fresnel_AD
!




END MODULE CRTM_OCEANEM_AMSRE


!---------------------------------------------------------------------------------
!                          -- MODIFICATION HISTORY --
!---------------------------------------------------------------------------------
!
! $Id:  $
!
! $Date:  $
!
! $Revision:  $
!
! $Name:  $
!
! $State: Exp $
!
! $Log:  $
!
