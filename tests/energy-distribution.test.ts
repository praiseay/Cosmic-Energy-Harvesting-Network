import { describe, it, beforeEach, expect } from "vitest"

describe("Energy Distribution Contract", () => {
  let mockStorage: Map<string, any>
  let totalEnergy: number
  
  beforeEach(() => {
    mockStorage = new Map()
    totalEnergy = 0
  })
  
  const mockContractCall = (method: string, args: any[]) => {
    switch (method) {
      case "allocate-energy":
        const [civilizationId, amount] = args
        if (totalEnergy + amount > 1000000000000) return { success: false, error: 401 }
        const currentAllocation = mockStorage.get(`civilization-${civilizationId}`) || 0
        mockStorage.set(`civilization-${civilizationId}`, currentAllocation + amount)
        totalEnergy += amount
        return { success: true }
      
      case "use-energy":
        const [useEnergyId, useAmount] = args
        const currentEnergy = mockStorage.get(`civilization-${useEnergyId}`) || 0
        if (currentEnergy < useAmount) return { success: false, error: 401 }
        mockStorage.set(`civilization-${useEnergyId}`, currentEnergy - useAmount)
        totalEnergy -= useAmount
        return { success: true }
      
      case "get-energy-allocation":
        return { success: true, value: { allocated_energy: mockStorage.get(`civilization-${args[0]}`) || 0 } }
      
      case "get-total-energy":
        return { success: true, value: totalEnergy }
      
      default:
        return { success: false, error: "Unknown method" }
    }
  }
  
  it("should allocate energy", () => {
    const result = mockContractCall("allocate-energy", [1, 1000000])
    expect(result.success).toBe(true)
  })
  
  it("should not allocate energy beyond capacity", () => {
    mockContractCall("allocate-energy", [1, 999999999999])
    const result = mockContractCall("allocate-energy", [2, 1000000000])
    expect(result.success).toBe(false)
    expect(result.error).toBe(401)
  })
  
  it("should use energy", () => {
    mockContractCall("allocate-energy", [1, 1000000])
    const result = mockContractCall("use-energy", [1, 500000])
    expect(result.success).toBe(true)
  })
  
  it("should not use more energy than allocated", () => {
    mockContractCall("allocate-energy", [1, 1000000])
    const result = mockContractCall("use-energy", [1, 1500000])
    expect(result.success).toBe(false)
    expect(result.error).toBe(401)
  })
  
  it("should get energy allocation", () => {
    mockContractCall("allocate-energy", [1, 1000000])
    const result = mockContractCall("get-energy-allocation", [1])
    expect(result.success).toBe(true)
    expect(result.value).toEqual({ allocated_energy: 1000000 })
  })
  
  it("should get total energy", () => {
    mockContractCall("allocate-energy", [1, 1000000])
    mockContractCall("allocate-energy", [2, 2000000])
    const result = mockContractCall("get-total-energy", [])
    expect(result.success).toBe(true)
    expect(result.value).toBe(3000000)
  })
})

