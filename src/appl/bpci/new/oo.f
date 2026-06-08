*
*     ------------------------------------------------------------
*        Z Z
*     ------------------------------------------------------------
*
      Double precision FUNCTION ZZ(i1,i2,i3,i4,K)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      Parameter (NOD=220)
      POINTER(IQP,P(NOD,1)),(IQN,N(1)),(IQL,L(1)),(IQAZ,AZ(1)),
     :       (IQMAX,MAX(1))
      COMMON/NEL/IQP,IQN,IQL,IQAZ,IQMAX,IQ(7)
      C= 2*k*(k+1)
      ZZ = - C * (TK(I1,I2,I3,I4,K+1) - TK(I1,I2,I3,I4,K-1))
*
      C1= L(i1)*(L(i1)+1) - L(i3)*(L(i3)+1) - k*(k+1)
      ZZ = ZZ - C1 * (UK(I1,I2,I3,I4,K+1) - UK(I1,I2,I3,I4,K-1))
*
      C2= L(i2)*(L(i2)+1) - L(i4)*(L(i4)+1) - k*(k+1)
      ZZ = ZZ - C2 * (UK(I2,I1,I4,I3,K+1) - UK(I2,I1,I4,I3,K-1))
*
      C= C1*C2/2
      C1= C*(k-2)/k/(k+k-1)
      C2= C*(k+3)/(k+1)/(k+k+3)
      ZZ = ZZ - C1 * (SN(I1,I2,I3,I4,K-2) + SN(I2,I1,I4,I3,K-2) )
     :        + C2 * (SN(I1,I2,I3,I4,K)   + SN(I2,I1,I4,I3,K) )
      RETURN
      END
*     ------------------------------------------------------------------
*              T K
*     ------------------------------------------------------------------
*

      DOUBLE PRECISION FUNCTION  TK(I,II,J,JJ,K)
      PARAMETER (NOD=220)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      COMMON /PARAM/H,H1,H3,CH,EH,RHO,Z,TOL,NO,ND,NWF,MASS,NCFG,IB,IC,ID
     :   ,D0,D1,D2,D3,D4,D5,D6,D8,D10,D12,D16,D30,FINE,NSCF,NCLOSD,RMASS
      COMMON /RADIAL/R(NOD),RR(NOD),R2(NOD),YK(NOD),YR(NOD),X(NOD)
      POINTER(IQP,P(NOD,1)),(IQN,N(1)),(IQL,L(1)),(IQAZ,AZ(1)),
     :       (IQMAX,MAX(1))
      COMMON/NEL/IQP,IQN,IQL,IQAZ,IQMAX,IQ(7)
c
      Call DZK(II,JJ,k)
      CALL YKK(II,JJ,K,1)
c
      DEN = L(I)+ L(J)+ 2
      FACT = L(J)
      D =  FACT*P(3,I)*P(3,J)*YK(3)/DEN
c
      MX = MIN0(MAX(I),MAX(J)) - 1
      Do M =3,MX
       S = (-P(M+2,J) + D8*(P(M+1,J)-P(M-1,J)) + P(M-2,J))/(D6*H)
       YK(M) = D5*P(M,I)*(S - P(M,J))*YK(M)
      End do
c
      S1=D0
      S2=D0
      Do M = 4,MX,2
       S1 = S1 + YK(m)
       S2 = S2 + YK(m+1)
      End do
c
      TK = D + H1*(S2 + D2*S1 + D5*YK(3))
      TK = TK / (k+k+1) * FINE
      RETURN
      END
*     ------------------------------------------------------------------
*              D Z K
*     ------------------------------------------------------------------
*
*       Stores in YK the values of the integral of
*              k
*       P (s/r) (dP /ds - P /s) integrated over the interval (0,r)
*        i         j       j
*
*   which enter into the spin-orbit calculation.
*
*
      SUBROUTINE DZK(I,J,K)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      PARAMETER(NOD=220)
      COMMON /PARAM/H,H1,H3,CH,EH,RHO,Z,TOL,NO,ND,NWF,MASS,NCFG,IB,IC,ID
     :   ,D0,D1,D2,D3,D4,D5,D6,D8,D10,D12,D16,D30,FINE,NSCF,NCLOSD,RMASS
      COMMON /RADIAL/R(NOD),RR(NOD),R2(NOD),YK(NOD),YR(NOD),X(NOD)
      POINTER(IQP,P(NOD,1)),(IQN,N(1)),(IQL,L(1)),(IQAZ,AZ(1)),
     :       (IQMAX,MAX(1))
      COMMON/NEL/IQP,IQN,IQL,IQAZ,IQMAX,IQ(7)
c
      LI=L(i)+1
      LJ=L(j)
      ZR = Z*R(4)
      BJ = ( P(4,J)/(AZ(J)*R2(4)*R(4)**LJ) - D1 + ZR/(LJ+1) )/ZR**2
c
      DEN = LI+ LJ + K + 1
      DI = D1/LI
      if(LJ.gt.0) DJ = D1/LJ
      if(LJ.eq.0) DJ = D2*BJ
      FACT = (DI + DJ)/(DEN + D1)
      ZR = Z*R(1)
      F1 = AZ(J)*R(1)**LJ*(LJ - ZR + BJ*(LJ+2)*ZR**2)
      F1 = R(1)*R2(1)*P(1,I)*F1
      YK(1) = F1*(D1 + ZR*FACT)/DEN
      ZR = Z*R(2)
      F2 = AZ(J)*R(2)**LJ*(LJ - ZR + BJ*(LJ+2)*ZR**2)
      F2 = R(2)*R2(2)*P(2,I)*F2
      YK(2) = F2*(D1 + ZR*FACT)/DEN
c
      A = EH**K
      AA = A*A
      A = D4*A
      Do 1 M =3,ND
       F3 = (-P(M+2,J) + D8*(P(M+1,J)-P(M-1,J)) + P(M-2,J))/(D6*H)
       F3 = D5*P(M,I)*(F3 - P(M,J))*R(M)
       YK(M) = YK(M-2)*AA + H3*(F3+ A*F2 + AA*F1)
       F1 = F2
       F2 = F3
    1 Continue
      RETURN
      END

*     ------------------------------------------------------------------
*            Y K K
*     ------------------------------------------------------------------
*
*       Stores in YK-array the values of the YK integral
*
      SUBROUTINE YKK(I,J,k,kk)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      PARAMETER(NOD=220)
      COMMON /PARAM/H,H1,H3,CH,EH,RHO,Z,TOL,NO,ND,NWF,MASS,NCFG,IB,IC,ID
     :   ,D0,D1,D2,D3,D4,D5,D6,D8,D10,D12,D16,D30,FINE,NSCF,NCLOSD,RMASS
      COMMON /RADIAL/R(NOD),RR(NOD),R2(NOD),YK(NOD),YR(NOD),X(NOD)
      POINTER(IQP,P(NOD,1)),(IQN,N(1)),(IQL,L(1)),(IQAZ,AZ(1)),
     :       (IQMAX,MAX(1))
      COMMON/NEL/IQP,IQN,IQL,IQAZ,IQMAX,IQ(7)
c
      B = EH**k
      A = B*EH**kk
      AA = A*A
      A = D4*A
      C = 2*k+kk
      HH = C*H3
      F2 = YK(ND)*B
      F1 = F2*B
      DO 9 MM = 3,NO
      M = NO -MM+1
      F3 =YK(M)
      YK(M) = YK(M+2)*AA + HH*(F3 +A*F2 + AA*F1)
      F1 = F2
9     F2 = F3
      RETURN
      END
C----------------------------------------------------------------------
C        U K
C---------------------------------------------------------------------


      DOUBLE PRECISION FUNCTION UK(I,J,II,JJ,K)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      COMMON /PARAM/H,H1,H3,CH,EH,RHO,Z,TOL,NO,ND,NWF,MASS,NCFG,IB,IC,ID
     :   ,D0,D1,D2,D3,D4,D5,D6,D8,D10,D12,D16,D30,FINE,NSCF,NCLOSD,RMASS
c
      CALL DZK(J,JJ,K)
      UK1 = QUADS(I,II,2)
c
      CALL YKK(J,JJ,K,1)
      UK2 = QUADS(I,II,2)
c
      UK = (UK1 - (k+2.)/(k+k+1.)*UK2) * fine  
      RETURN
      END
*
*     ------------------------------------------------------------------
*              S N
*     ------------------------------------------------------------------
*
*                                      3              k
*       Evaluates the integral of (1/r)  P (r) P (r) Z (i, j; r)  with
*                                         i     j
*   respect to r.
*
      DOUBLE PRECISION FUNCTION SN(I,J,II,JJ,K)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      COMMON /PARAM/H,H1,H3,CH,EH,RHO,Z,TOL,NO,ND,NWF,MASS,NCFG,IB,IC,ID
     :   ,D0,D1,D2,D3,D4,D5,D6,D8,D10,D12,D16,D30,FINE,NSCF,NCLOSD,RMASS
      CALL ZK(J,JJ,K)
      SN = QUADS(I,II,3)*FINE
      RETURN
      END
