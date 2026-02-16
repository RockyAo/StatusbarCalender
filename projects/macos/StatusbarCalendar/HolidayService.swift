//
//  HolidayService.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import Foundation

/// 节假日服务 - 管理节假日数据的获取、存储和查询
@Observable @MainActor
final class HolidayService {
    private let database: HolidayDatabase
    private var cachedHolidays: [String: StoredHoliday] = [:]
    private var lastSyncDate: Date?
    private let apiURL = "https://timor.tech/api/holiday/year"
    private let dateFormatter: DateFormatter
    
    /// 是否正在同步数据
    private(set) var isSyncing = false
    
    init() {
        // 初始化日期格式化器
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.database = HolidayDatabase()
        
        // 从数据库加载缓存数据
        self.cachedHolidays = database.getAllHolidays()
        
        print("📅 HolidayService initialized with \(cachedHolidays.count) cached holidays")
        
        // 检查并自动同步
        Task {
            await checkAndSync()
        }
    }
    
    // MARK: - Public Methods
    
    /// 获取指定日期的节假日状态
    func getStatus(for date: Date) -> DayStatus {
        let dateString = formatDate(date)
        
        if let holiday = cachedHolidays[dateString] {
            return holiday.isHoliday ? .holiday : .workday
        }
        
        return .normal
    }
    
    /// 获取指定日期的节假日名称
    func getHolidayName(for date: Date) -> String? {
        let dateString = formatDate(date)
        return cachedHolidays[dateString]?.name
    }
    
    /// 手动触发同步
    func syncNow() async {
        await fetchAndSaveHolidays()
    }
    
    // MARK: - Private Methods
    
    /// 检查是否需要同步（每天一次）
    private func checkAndSync() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 检查上次同步时间
        if let lastSyncDateString = database.getMetadata(key: "last_sync_date"),
           let lastSyncDate = dateFormatter.date(from: lastSyncDateString) {
            let lastSyncDay = calendar.startOfDay(for: lastSyncDate)
            
            // 如果今天已经同步过，跳过
            if lastSyncDay == today {
                print("✅ Holiday data already synced today")
                return
            }
        }
        
        // 执行同步
        await fetchAndSaveHolidays()
    }
    
    /// 从 API 获取节假日数据并保存到数据库
    private func fetchAndSaveHolidays() async {
        guard !isSyncing else {
            print("⚠️ Sync already in progress")
            return
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        // 获取当前年份
        let currentYear = Calendar.current.component(.year, from: Date())
        
        do {
            print("🔄 Fetching holiday data for \(currentYear)...")
            
            guard let url = URL(string: apiURL) else {
                print("❌ Invalid URL")
                return
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ HTTP request failed")
                return
            }
            
            // 解析 JSON
            let decoder = JSONDecoder()
            let holidayResponse = try decoder.decode(HolidayResponse.self, from: data)
            
            guard holidayResponse.code == 0 else {
                print("❌ API returned error code: \(holidayResponse.code)")
                return
            }
            
            print("✅ Fetched \(holidayResponse.holiday.count) holidays from API")
            
            // 保存到数据库
            database.saveHolidays(holidayResponse.holiday, year: currentYear)
            
            // 更新缓存
            cachedHolidays = database.getAllHolidays()
            
            print("✅ Holiday data synced successfully")
            
        } catch {
            print("❌ Failed to fetch holidays: \(error.localizedDescription)")
        }
    }
    
    /// 格式化日期为 YYYY-MM-DD 格式
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
