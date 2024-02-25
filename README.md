# Production-planning-considering-machine-failures: Simulation-Optimization Approach
### Model description
* Language model: Mathlab
* Optimization methodology: Genetic Algorithm (GA), Power law Non-Homogenous Poisson Process (PL-NHPP)
### **Objective**
The current maintenance and failures factors are independent with production plan. Thus, the objective of this study is to create the optimal production planning that considers failure factors in order to minimize inventory cost and meet the delivery date. Simulation-Optimization method has been used to enhance the accuracy of the models and give optimal solution under different scenarios. 
### **Scope**
The study mainly focusses on production of electric assembly product. The simulation model is built monthly, based on historical activities of one cell having 6 product families, represents in 63 references. The dataset is collected primarily in 2 main categories: production plan, metric related to product and maintenance activities. 
### **Maintenance and Reliability**
#### **Maintenance**
Machines after a certain amount of time in use, will not only depreciate but also have its function reduced. Each equipment has its own lifetime, at the time point P (potential failure point), there will be detectable signals of failures, the equipment starts losing its function. After a period, at the point F (functional failure point), the machine almost totally loses its function and can stop production running. Thus, to prevent this, frequent maintenance is conducted by the maintenance technician throughout each machine’s lifetime, at the suitable time before it reaches the F point.
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/6e95536e-34ef-4291-83b2-82b78e2d500e)
* ***P – potential failure point:** point where wear or loss of functionality is detectable*
* ***F – functional failure point:** point where component lost required functionality*
#### **Reliability**
Reliability is defined as the probability that a component, equipment or machine performs its function for a specified period of time, when operating in its design environment. \
Reliability can be considered as a function of time. As a result, a clear criterion for assessing whether something is working or not, as well as the precise characterization of environmental conditions and usage, are required for the definition of reliability. If we assume that a component is used for its intended function in its design environment and if we explicitly define "failure," reliability can be defined as the time-dependent probability of correct operation. Any study of the fundamentals of reliability, according to this definition, must begin with a review of the essential ideas of probability.
### **Genetic algorithm (GA)**
The concept of GA algorithm is from Charles Darwin’s theory of evolution. This algorithm simulates natural selection, in which the fittest individuals are chosen for reproduction in order to produce the next generation's progeny. Using operators inspired by natural behaviors including as mutation, crossover, and selection, genetic algorithms are frequently used to produce high-quality solutions to optimization and search problems.
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/9121be9c-9454-4a45-a1ed-fcb2f980924f)
### **Optimization model:** 
The main objective is to minimize the tardiness amount of production and inventory cost. To solve this problem, GA is proposed to ensure the converges towards the best global optimal solutions. Each chromosome represents the sequence of selecting product families and their quantity for production planning.\
* Inventory calculation\
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/9cc856a9-f36c-4ba1-8d05-b7ff2667fb35)
* Age of machines at each failure\
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/c576005b-5d93-4c7d-aa9c-1ab1c2ece67e)
* Expected number of failure and repair rate by Weibull distribution\
The expected number of failures by time t is expressed by:\
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/7a56169d-c3a0-4421-860c-593e05feb353)\
The repair rate following the Power law Non-Homogenous Poisson Process (PL-NHPP):\
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/135e589b-de12-468a-8903-cb4e616fe1a3)\
where\
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/bec876b7-07ba-4449-94fc-fb75d388fabf)\
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/1c51c716-e5d8-45b3-8a65-2b383c97dac7)
* The next failures occurring at time T for an NHPP follows CDF as:\
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/31e4dce2-2c83-40a0-b58b-4acca205b4dc)

### Result
***Inventory cost for 1000 replication of simulation***
![image](https://github.com/Desnyyy/Production-planning-considering-machine-failures/assets/88900307/17a8841a-9b02-4db0-afc4-b26f3ba72eda)
* **Simulation-optimization brings the lowest cost** because it **considers failures** of the systems to have better planning. In contrast, a **deterministic plan does not consider the failure**, **inventory cost** should get **higher** since failures cause unavailability of the machine, and that delays are likely to occur. When machines break and all the workstations have to stop, the production order is delayed. Since no constraint for that scenario is assigned, the remaining-not-fished is counted for penalty, and thus cost extremely high in inventory cost.
* The **real system** of the factory tries to optimize planning by predicting the unexpected happening. However, **lateness cannot be prevented totally, inventory cost still rising** upward and high.
that led to the amount of rescheduling and thus, increase in inventory volume. 
* The results draw a conclusion that the proposed model is better than the current one and considering failures factor is important for production planning.







