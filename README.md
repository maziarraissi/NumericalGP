# Numerical Gaussian Processes

We introduce the concept of numerical Gaussian processes, which we define as Gaussian processes with covariance functions resulting from temporal discretization of time-dependent partial differential equations. Numerical Gaussian processes, by construction, are designed to deal with cases where: (1) all we observe are noisy data on black-box initial conditions, and (2) we are interested in quantifying the uncertainty associated with such noisy data in our solutions to time-dependent partial differential equations. Our method circumvents the need for spatial discretization of the differential operators by proper placement of Gaussian process priors. This is an attempt to construct structured and data-efficient learning machines, which are explicitly informed by the underlying physics that possibly generated the observed data. The effectiveness of the proposed approach is demonstrated through several benchmark problems involving linear and nonlinear time-dependent operators. In all examples, we are able to recover accurate approximations of the latent solutions, and consistently propagate uncertainty, even in cases involving very long time integration.

For more details, please refer to the following:

- Raissi, Maziar, Paris Perdikaris, and George Em Karniadakis. "[Numerical Gaussian Processes for Time-dependent and Non-linear Partial Differential Equations.](https://arxiv.org/abs/1703.10230)" arXiv preprint arXiv:1703.10230 (2017).

- Slides: [Numerical Gaussian Processes](https://icerm.brown.edu/materials/Slides/tw-17-4/Numerical_Gaussian_Processes_for_Time-dependent_and_Non-linear_Partial_Differential_Equations_%5D_Maziar_Raissi,_Brown_University.pdf)

- Video: [Numerical Gaussian Processes](https://icerm.brown.edu/video_archive/#/play/1306)

## Citation

    @article{raissi2017numerical,
      title={Numerical Gaussian Processes for Time-dependent and Non-linear Partial Differential Equations},
      author={Raissi, Maziar and Perdikaris, Paris and Karniadakis, George Em},
      journal={arXiv preprint arXiv:1703.10230},
      year={2017}
    }
