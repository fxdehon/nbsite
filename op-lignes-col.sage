#F-X. Dehon - dec 2016, mars 2021, mai 2021
#showop modifié le 23 mars 2021 : liste de chaînes de caractères
#fsmith modifié le 23 mars 2021 : opérations triviales éliminées.
#showtransf créé le 15 mai 2021
#showop modifié le 18 mai 2021
#ech_col créé le 15 février 2023

import copy #B=copy.deepcopy(A)

def showop(o): # affichage d'une liste d'opérations
    l=[]
    for op in o:
        t,i,j=op[:3]
        if t==1 or t==2:
            a=op[3]
            if a>=0:
                plus="+"
                if a!=1:plus=plus+str(a)
            else:
                plus="-"
                if a!=-1:plus=plus+str(abs(a))
        if t==1:Arrow="C"+str(i)+plus+"C"+str(j)+" → C"+str(i)
        elif t==2:Arrow="L"+str(i)+plus+"L"+str(j)+" → L"+str(i)
        elif t==3:Arrow="C"+str(i)+" ↔ C"+str(j)
        elif t==4:Arrow="L"+str(i)+" ↔ L"+str(j)
        l=l+[Arrow]
    return(l)

def tradop(o):
    lop=[]
    for op in o:
        if op[0]==1:lop=lop+[[9-2*len(op)]+op[1:]]
        elif op[0]==0:lop=lop+[[10-2*len(op)]+op[1:]]
    return(lop)
    
def tradnop(o):
	lop=[]
	for op in o:
		if op[0]%2==1:lop=lop+[[1]+op[1:]]
		else:lop=lop+[[0]+op[1:]]
	return(lop)

def lshowtransf(A,o):
    B=copy.deepcopy(A) #sinon A est modifié
    l=[]
    for op in o:
        t,i,j=op[:3]
        if t==1 or t==2:
            a=op[3]
            if a>=0:
                plus="+"
                if a!=1:plus=plus+str(a)
            else:
                plus="-"
                if a!=-1:plus=plus+str(abs(a))
        if t==1:
            C=B.with_added_multiple_of_column(i-1,j-1,a)
            Arrow=LatexExpr(r"\xrightarrow[C_{"+str(i)\
                  +r"}"+plus+r"C_{"+str(j)+r"}\to C_{"+str(i)+r"}]{}")
        elif t==2:
            C=B.with_added_multiple_of_row(i-1,j-1,a)
            Arrow=LatexExpr(r"\xrightarrow[L_{"+str(i)\
                  +r"}"+plus+r"L_{"+str(j)+r"}\to L_{"+str(i)+r"}]{}")
        elif t==3:
            C=B.with_swapped_columns(i-1,j-1)
            Arrow=LatexExpr(r"\xrightarrow[C_{"+str(i)\
                  +r"}\leftrightarrow C_{"+str(j)+r"}]{}")
        elif t==4:
            C=B.with_swapped_rows(i-1,j-1)
            Arrow=LatexExpr(r"\xrightarrow[L_{"+str(i)\
                  +r"}\leftrightarrow L_{"+str(j)+r"}]{}")
        l=l+[Arrow+latex(C)]
        B=C
    return(l)

def showtransf(A,tlop,nshowop=2,pre="A=",post="=D"):
    lT=lshowtransf(A,tlop)
    if len(lT)>nshowop:
      show(pre,A,*[lT.pop(0) for x in range(nshowop)]);show("")
      while len(lT)>nshowop:
        show(*[lT.pop(0) for x in range(nshowop)]);show("")
      show(*lT,post);show("")
    else:
      show(pre,A,*lT,post)
    
def printlop(llop,nshowop=2):
    if len(llop)>nshowop:
      print("lop=["+"".join([str(llop.pop(0))+"," for x in range(nshowop)])+"\\")
      while len(llop)>nshowop:
        print("".join([str(llop.pop(0))+"," for x in range(nshowop)])+"\\")
      print("".join([str(o)+"," for o in llop])+"]")
    else:
      print("lop=["+"".join([str(o)+"," for o in llop])+"]")

def inv(o):
    n=len(o)
    if n==0:return(o)
    else:
        if o[n-1][0] in [3,4]:op=o[n-1]
        else:op=o[n-1][:3]+[-o[n-1][3]]
        return([op]+inv(o[:n-1]))

def transf(A,o): #transformation d'une matrice A suivant la liste d'opération o
    B=copy.deepcopy(A) #sinon A est modifié
    for op in o:
        if op[0]==1:B[:,op[1]-1]=B[:,op[1]-1]+op[3]*B[:,op[2]-1]
        elif op[0]==2:B[op[1]-1,:]=B[op[1]-1,:]+op[3]*B[op[2]-1,:]
        elif op[0]==3:
            C=B[:,op[1]-1];B[:,op[1]-1]=B[:,op[2]-1];B[:,op[2]-1]=C
        elif op[0]==4:
            L=B[op[1]-1,:];B[op[1]-1,:]=B[op[2]-1,:];B[op[2]-1,:]=L
    return(B)

def fsmith(A):
    p=A.nrows();q=A.ncols()
    L=[abs(A[i][j]) for i in range(p) for j in range(q)]
    if p*q==0 or max(L)==0:
        return([])
    else:
        a=min(L[i] for i in range(p*q) if L[i]!=0)
        k=L.index(a);i0=k//q;j0=k%q;a=A[i0][j0] #a avec signe
        l=[i for i in range(p*q) if L[i]%a!=0]
        if l==[]:  #pivot suivant a
            o=[[1,j+1,j0+1,-A[i0][j]/a] for j in [0..q-1] if j!=j0 and A[i0][j]!=0]\
                + [[2,i+1,i0+1,-A[i][j0]/a] for i in [0..p-1] if i!=i0 and A[i][j0]!=0]
            if j0!=0:o=o+[[3,1,j0+1]]
            if i0!=0:o=o+[[4,1,i0+1]]
            return(o+[[op[0],1+op[1],1+op[2]]+op[3:] for op in fsmith(transf(A,o).submatrix(1,1))])
        else: #vers l'apparition du pgcd des coeff de A comme coeff de A
            k=min(l);i1=k//q;j1=k%q;b=A[i1][j1]
            if A[i0][j1]%a != 0:
                o=[[1,j1+1,j0+1,-(A[i0][j1]//a)]]
            elif A[i1][j0]%a != 0:
                o=[[2,i1+1,i0+1,-(A[i1][j0]//a)]]
            else:
                o=[[2,i1+1,i0+1,-(A[i1][j0]//a)],[2,i0+1,i1+1,1],\
                   [1,j1+1,j0+1,-(((1-A[i1][j0]//a)*A[i0][j1]+b)//a)]]
            return(o+fsmith(transf(A,o)))

def ech_col(A): # 15fev23
    p=A.nrows();q=A.ncols()
    if p*q==0:
        return([])
    else:
       	o=fsmith(A.submatrix(0,0,1))
        return(o+[[op[0],1+op[1],1+op[2]]+op[3:] for op in ech_col(transf(A,o).submatrix(1,1))])
