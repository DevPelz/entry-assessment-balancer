Build a simple yielding contract that tracks users' deposit of fee-on-transfer tokens, and these tokens are deposited into a Balancer pool. You can optionally choose to use a wrapper token to represent the underlying token between the Balancer pool and the yielding contract. Ensure that the Balancer pool implements the “feel-on-pool-entry” mechanism. Based on the deposit, users accrue rewards based on pool performance and distribute to depositors.

Protocol Flow

a. Users deposit into the yielding contract

b. Deposited tokens are added to the Balancer pool

c. The Balancer pool generates rewards through trading fee and fee-on-pool mechanism

d. The yielding contracts generates rewards and distributes to token depositors

e. Users can withdraw their tokens from the yielding contract considering the accrued fees and rewards
