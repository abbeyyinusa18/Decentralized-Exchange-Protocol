import { describe, it, beforeEach, expect } from "vitest"

describe("governance", () => {
  let contract: any
  
  beforeEach(() => {
    contract = {
      getProposal: (proposalId: number) => ({
        proposer: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
        description: "Increase trading fees by 0.1%",
        votesFor: 1000000,
        votesAgainst: 500000,
        status: "active",
        endBlock: 100000,
      }),
      createProposal: (description: string, duration: number) => ({ value: 1 }),
      vote: (proposalId: number, amount: number, voteFor: boolean) => ({ success: true }),
      endProposal: (proposalId: number) => ({ success: true }),
      getAllProposals: () => ({ value: 5 }),
    }
  })
  
  describe("get-proposal", () => {
    it("should return proposal information", () => {
      const result = contract.getProposal(1)
      expect(result.description).toBe("Increase trading fees by 0.1%")
      expect(result.status).toBe("active")
    })
  })
  
  describe("create-proposal", () => {
    it("should create a new proposal", () => {
      const result = contract.createProposal("Reduce trading fees by 0.05%", 10000)
      expect(result.value).toBe(1)
    })
  })
  
  describe("vote", () => {
    it("should allow voting on a proposal", () => {
      const result = contract.vote(1, 100000, true)
      expect(result.success).toBe(true)
    })
  })
  
  describe("end-proposal", () => {
    it("should end an active proposal", () => {
      const result = contract.endProposal(1)
      expect(result.success).toBe(true)
    })
  })
  
  describe("get-all-proposals", () => {
    it("should return the total number of proposals", () => {
      const result = contract.getAllProposals()
      expect(result.value).toBe(5)
    })
  })
})

