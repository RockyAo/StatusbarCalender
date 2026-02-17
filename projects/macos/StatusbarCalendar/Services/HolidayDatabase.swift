//
//  HolidayDatabase.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import Foundation
import SQLite3

/// SQLite 数据库管理器 - 存储节假日数据
final class HolidayDatabase: Sendable {
    private let dbPath: String
    private nonisolated(unsafe) var db: OpaquePointer?
    private let dateFormatter: DateFormatter
    
    nonisolated static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    nonisolated init(baseDirectory: URL? = nil, bundleID: String? = Bundle.main.bundleIdentifier) {
        self.dateFormatter = Self.makeDateFormatter()
        
        // 数据库存储在 Application Support 目录
        let fileManager = FileManager.default
        let appDirectory: URL
        if let baseDirectory = baseDirectory {
            appDirectory = baseDirectory
        } else {
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let resolvedBundleID = bundleID ?? "com.example.StatusbarCalendar"
            appDirectory = appSupport.appendingPathComponent(resolvedBundleID, isDirectory: true)
        }
        
        // 创建目录（如果不存在）
        try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        
        self.dbPath = appDirectory.appendingPathComponent("holidays.db").path
        
        print("📂 Database path: \(dbPath)")
        
        self.openDatabase()
        self.migrateIfNeeded()
        self.createTableIfNeeded()
    }
    
    deinit {
        closeDatabase()
    }
    
    // MARK: - Database Operations
    
    private func openDatabase() {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("✅ Database opened successfully")
        } else {
            print("❌ Failed to open database")
        }
    }
    
    private func closeDatabase() {
        if db != nil {
            sqlite3_close(db)
            db = nil
        }
    }
    
    private func migrateIfNeeded() {
        // 检查是否存在旧的 wage 字段
        let checkColumnSQL = "PRAGMA table_info(holidays)"
        var statement: OpaquePointer?
        var hasWageColumn = false
        
        if sqlite3_prepare_v2(db, checkColumnSQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let columnName = sqlite3_column_text(statement, 1) {
                    let name = String(cString: columnName)
                    if name == "wage" {
                        hasWageColumn = true
                        break
                    }
                }
            }
        }
        sqlite3_finalize(statement)
        
        // 如果存在旧字段，删除表重建
        if hasWageColumn {
            print("🔄 Migrating database schema...")
            sqlite3_exec(db, "DROP TABLE IF EXISTS holidays", nil, nil, nil)
            print("✅ Old schema removed")
        }
    }
    
    private func createTableIfNeeded() {
        let createTableSQL = """
        CREATE TABLE IF NOT EXISTS holidays (
            date TEXT PRIMARY KEY,
            is_holiday INTEGER NOT NULL,
            name TEXT NOT NULL,
            days INTEGER NOT NULL,
            updated_at TEXT NOT NULL
        );
        
        CREATE TABLE IF NOT EXISTS metadata (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        );
        """
        
        var error: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(db, createTableSQL, nil, nil, &error) == SQLITE_OK {
            print("✅ Tables created successfully")
        } else {
            if let error = error {
                let errorMessage = String(cString: error)
                print("❌ Failed to create tables: \(errorMessage)")
                sqlite3_free(error)
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 保存节假日数据
    func saveHolidays(_ holidays: [HolidayDay], year: Int) {
        let now = dateFormatter.string(from: Date())
        
        // 开始事务
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        
        let insertSQL = "INSERT OR REPLACE INTO holidays (date, is_holiday, name, days, updated_at) VALUES (?, ?, ?, ?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            var successCount = 0
            
            for holiday in holidays {
                sqlite3_bind_text(statement, 1, (holiday.date as NSString).utf8String, -1, nil)
                sqlite3_bind_int(statement, 2, holiday.holiday ? 1 : 0)
                sqlite3_bind_text(statement, 3, (holiday.name as NSString).utf8String, -1, nil)
                sqlite3_bind_int(statement, 4, Int32(holiday.days))
                sqlite3_bind_text(statement, 5, (now as NSString).utf8String, -1, nil)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    successCount += 1
                }
                
                sqlite3_reset(statement)
            }
            
            print("✅ Saved \(successCount) holidays to database")
        }
        
        sqlite3_finalize(statement)
        
        // 提交事务
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
        
        // 更新最后同步时间
        setMetadata(key: "last_sync_year", value: "\(year)")
        setMetadata(key: "last_sync_date", value: now)
    }
    
    /// 查询指定日期的节假日状态
    func getHoliday(for date: String) -> DayStatus {
        let querySQL = "SELECT is_holiday FROM holidays WHERE date = ?"
        var statement: OpaquePointer?
        var status: DayStatus = .normal
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (date as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let isHoliday = sqlite3_column_int(statement, 0)
                status = isHoliday == 1 ? .holiday : .workday
            }
        }
        
        sqlite3_finalize(statement)
        return status
    }
    
    /// 获取所有节假日数据（用于缓存）
    func getAllHolidays() -> [String: StoredHoliday] {
        let querySQL = "SELECT date, is_holiday, name, days FROM holidays"
        var statement: OpaquePointer?
        var holidays: [String: StoredHoliday] = [:]
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let date = String(cString: sqlite3_column_text(statement, 0))
                let isHoliday = sqlite3_column_int(statement, 1) == 1
                let name = String(cString: sqlite3_column_text(statement, 2))
                let days = Int(sqlite3_column_int(statement, 3))
                
                let holiday = StoredHoliday(
                    date: date,
                    isHoliday: isHoliday,
                    name: name,
                    days: days
                )
                
                holidays[date] = holiday
            }
        }
        
        sqlite3_finalize(statement)
        return holidays
    }
    
    /// 获取元数据
    func getMetadata(key: String) -> String? {
        let querySQL = "SELECT value FROM metadata WHERE key = ?"
        var statement: OpaquePointer?
        var value: String?
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (key as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                value = String(cString: sqlite3_column_text(statement, 0))
            }
        }
        
        sqlite3_finalize(statement)
        return value
    }
    
    /// 设置元数据
    func setMetadata(key: String, value: String) {
        let insertSQL = "INSERT OR REPLACE INTO metadata (key, value) VALUES (?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (key as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (value as NSString).utf8String, -1, nil)
            sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
}
