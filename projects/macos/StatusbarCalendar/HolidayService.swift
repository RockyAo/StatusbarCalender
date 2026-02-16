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
    private let apiURL = "https://date.appworlds.cn/year/"
    private let dateFormatter: DateFormatter
    
    /// 是否正在同步数据
    private(set) var isSyncing = false
    
    /// 最后更新时间 - 用于触发 UI 刷新
    private(set) var lastUpdateTime = Date()
    
    /// 已加载的年份集合
    private var loadedYears = Set<Int>()
    
    init() {
        // 初始化日期格式化器
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.database = HolidayDatabase()
        
        // 从数据库加载缓存数据
        self.cachedHolidays = database.getAllHolidays()
        
        // 初始化更新时间
        if !cachedHolidays.isEmpty {
            self.lastUpdateTime = Date()
        }
        
        print("📅 HolidayService initialized with \(cachedHolidays.count) cached holidays")
    }
    
    /// App 启动时调用 - 加载当前年份数据
    func checkAndSyncOnAppLaunch() async {
        let currentYear = Calendar.current.component(.year, from: Date())
        await ensureYearLoaded(currentYear)
    }
    
    /// 确保指定年份的数据已加载
    func ensureYearLoaded(_ year: Int) async {
        // 如果已经加载过，直接返回
        if loadedYears.contains(year) {
            return
        }
        
        // 检查数据库中是否有该年份的数据
        let hasDataInDB = cachedHolidays.values.contains { holiday in
            holiday.date.hasPrefix("\(year)-")
        }
        
        if hasDataInDB {
            print("✅ Year \(year) data already in cache")
            loadedYears.insert(year)
            return
        }
        
        // 从 API 获取
        await fetchAndSaveHolidays(for: year)
    }
    
    // MARK: - Public Methods
    
    /// 获取指定日期的节假日状态
    func getStatus(for date: Date) -> DayStatus {
        // 访问 lastUpdateTime 确保建立观察依赖
        _ = lastUpdateTime
        
        let dateString = formatDate(date)
        
        if let holiday = cachedHolidays[dateString] {
            return holiday.isHoliday ? .holiday : .workday
        }
        
        return .normal
    }
    
    /// 获取指定日期的节假日名称
    func getHolidayName(for date: Date) -> String? {
        // 访问 lastUpdateTime 确保建立观察依赖
        _ = lastUpdateTime
        
        let dateString = formatDate(date)
        return cachedHolidays[dateString]?.name
    }
    
    /// 手动触发同步
    func syncNow() async {
        let currentYear = Calendar.current.component(.year, from: Date())
        await fetchAndSaveHolidays(for: currentYear)
    }
    
    // MARK: - Private Methods
    
    /// 从 API 获取节假日数据并保存到数据库
    private func fetchAndSaveHolidays(for year: Int) async {
        guard !isSyncing else {
            print("⚠️ Sync already in progress")
            return
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            print("🔄 Fetching holiday data for \(year)...")
            
            // 构建带年份的 API URL
            let urlString = "\(apiURL)\(year)"
            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL: \(urlString)")
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
            
            guard holidayResponse.code == 200 else {
                print("❌ API returned error code: \(holidayResponse.code)")
                return
            }
            
            print("✅ Fetched \(holidayResponse.data.count) holidays from API")
            
            // 保存到数据库
            database.saveHolidays(holidayResponse.data, year: year)
            
            // 更新缓存
            cachedHolidays = database.getAllHolidays()
            
            // 标记年份已加载
            loadedYears.insert(year)
            
            // 触发 UI 刷新
            lastUpdateTime = Date()
            
            print("✅ Holiday data synced successfully for \(year)")
            
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
