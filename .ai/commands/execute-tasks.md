# Multi-Agent Task Execution

Execute the provided plan using three parallel agents, but ONLY after confirmation.

## Pre-Execution Phase (REQUIRED)
1. **Plan Analysis**: Review the plan against current codebase structure, dependencies, and constraints
2. **Execution Strategy**: Break down the plan into specific, actionable tasks for each agent
3. **Coordination Points**: Identify dependencies and integration requirements
4. **Strategy Confirmation**: Present complete execution strategy and WAIT for explicit approval
5. **Agent Spawn**: Only after confirmation, spawn the three agents to begin parallel execution

## Agent Specifications

### Agent 1: The Implementer
**Objective**: Execute core functionality according to plan specifications
**Responsibilities**:
- Implement all business logic and core features
- Follow existing code patterns and conventions
- Handle error cases and edge conditions
- Ensure integration with existing systems

**Success Criteria**: All specified functionality works correctly and integrates seamlessly

### Agent 2: The Tester
**Objective**: Create comprehensive test coverage for implemented features
**Responsibilities**:
- Write unit tests for all new functions/methods
- Create integration tests for feature workflows
- Add edge case and error condition tests
- Follow project's existing testing patterns and frameworks

**Success Criteria**: Meaningful test coverage that would catch regressions and validate functionality

### Agent 3: The Documenter
**Objective**: Update project documentation to reflect new functionality
**Responsibilities**:
- Update `/my-feature/README.md` in `.ai/docs` with new features
- Document API changes, configuration options, or usage patterns
- Update any affected architectural documentation
- Ensure documentation is accurate and user-friendly

**Success Criteria**: Complete, accurate documentation that enables users to understand and use new features

## Execution Protocol
- **DO NOT spawn agents until strategy is confirmed**
- Agents work in parallel assuming others will succeed
- Each agent focuses solely on their domain of responsibility
- No inter-agent communication required during execution
- All agents follow project conventions and quality standards
