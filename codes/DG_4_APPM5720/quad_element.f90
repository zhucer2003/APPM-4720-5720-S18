module quad_element
  use type_defs
  implicit none
  !
  type quad
     !  
     ! We envsion solving 
     !    M u_t + S u = Lu  
     !    
     ! The variables u and represents our fields
     ! The degree on the element for u is (0:q)^2 
     ! The third dimension of u refers to how many variables we have
     ! e.g. scalar advection equation has nvar = 1, Maxwell has nvar = 3.
     ! 
     ! Thus the mass matrix M is of dimension (nvar*(q)^2) x (nvar*(q)^2)
     ! and the stiffness matrix S is the same dimension
     !
     ! 
     ! Each quad can be mapped to the reference element [-1,1]^2
     ! The ordering of the nodes and faces are as follows:
     !        1
     !    2-------1
     !    |       |
     !  2 |       | 4
     !    |       |
     !    3-------4
     !        3
     !
     !  So side 2 has r = -1, side 3 has s = -1, etc.
     !
     ! The Gordon-Hall mapping used to compute the metric
     ! assumes down->up and left->right orientaiton of the sides.
     !
     ! 
     !%% Geometric information
     ! Number of quadrature points
     integer :: n_gll
     ! Four vertices
     real(kind=dp) :: xy(4,2)
     ! Metric
     real(kind=dp), dimension(:,:), allocatable :: jac, rx, ry, sx, sy
     ! Local coordinates on quadrature points and perhaps material coeff. 
     real(kind=dp), dimension(:,:), allocatable :: x, y, material_coeff
     !%% Connectivity information
     ! element #
     integer :: my_ind
     ! Neighbours quad nr, and what is their face?
     integer :: nbr(4,2)
     ! Note that the values on a side can be oriented in the same or opposite direction
     integer :: nbr_orientation(4)
     ! Boundary condition type > 0 is other element < 0 is physical BC
     integer :: bc_type(4)
     logical :: has_physical_bc
     !%% Information of the approximation
     integer :: q, nvar
     real(kind=dp), dimension(:,:,:), allocatable :: u,fu
     real(kind=dp), dimension(:,:),   allocatable :: M,S
     ! For LAPACK, if needed
     integer,       dimension(:),   allocatable :: IPIV

     ! Arrays for states on the quad to be used in the flux computation. 
     ! The velocity, gradient of F, the outward pointing normals and
     ! the line element on each face
     real(kind=dp), dimension(:,:,:), allocatable :: u_in
     real(kind=dp), dimension(:,:,:), allocatable :: u_out
     real(kind=dp), dimension(:,:)  , allocatable :: nx_in, ny_in, dl_face
          
  end type quad

contains

  subroutine allocate_quad(qd,q,n_gll,nvar)
    implicit none
    integer :: n_gll,q,nvar
    type(quad) :: qd
    qd%n_gll = n_gll
    qd%q = q
    qd%nvar = nvar

    ! Allocate approximation
    allocate(qd%u(0:q,0:q,nvar))
    allocate(qd%fu(0:q,0:q,nvar))
    allocate(qd%M(q**2*nvar,q**2*nvar))
    allocate(qd%S(q**2*nvar,q**2*nvar))
    allocate(qd%IPIV(q**2*nvar)) ! DEAA CHECK ME, right size? 
    
    ! Allocate metric
    allocate(qd%jac(n_gll,n_gll))
    allocate(qd%rx(n_gll,n_gll))
    allocate(qd%ry(n_gll,n_gll))
    allocate(qd%sx(n_gll,n_gll))
    allocate(qd%sy(n_gll,n_gll))
    
    ! Allocate grid and Lame parameters
    allocate(qd%x(n_gll,n_gll))
    allocate(qd%y(n_gll,n_gll))
    allocate(qd%material_coeff(n_gll,n_gll))
    ! Allocate face data
    allocate(qd%u_in(n_gll,4,nvar))
    allocate(qd%u_out(n_gll,4,nvar))
    allocate(qd%nx_in(n_gll,4))
    allocate(qd%ny_in(n_gll,4))
    allocate(qd%dl_face(n_gll,4))

  end subroutine allocate_quad

  subroutine deallocate_quad(qd)
    implicit none
    type(quad) :: qd
    ! DeAllocate approximation
    deallocate(qd%u)
    deallocate(qd%fu)
    deallocate(qd%s)
    deallocate(qd%m)
    deallocate(qd%ipiv)

    ! DeAllocate metric
    deallocate(qd%jac)
    deallocate(qd%rx)
    deallocate(qd%ry)
    deallocate(qd%sx)
    deallocate(qd%sy)

    ! DeAllocate grid 
    deallocate(qd%x)
    deallocate(qd%y)
    deallocate(qd%material_coeff)
    ! DeAllocate face data
    deallocate(qd%u_in)
    deallocate(qd%u_out)
    deallocate(qd%nx_in)
    deallocate(qd%ny_in)
    deallocate(qd%dl_face)

  end subroutine deallocate_quad

end module quad_element
