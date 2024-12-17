import UIKit
import CoreData

enum PickerType {
    case office
    case date
    case timeIn
    case timeOut
}


class EntriesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var workEntries: [WorkEntry] = [] // Store Core Data entries
    var officeList: [String] = ["Bronx", "212A", "308B", "PalmerRd"] // List of available offices
    
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Fetch saved work entries from Core Data
        fetchWorkEntries()
        
        // Reload the table view
        tableView.reloadData()
    }
    
    // MARK: - Fetch Work Entries from Core Data
    func fetchWorkEntries() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request for WorkEntry entities
        let fetchRequest: NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest()
        
        do {
            workEntries = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch work entries: \(error)")
        }
    }

    // MARK: - TableView DataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workEntryCell", for: indexPath) as! WorkEntryTableViewCell
        
        let entry = workEntries[indexPath.row]
        
        // Date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        // Ensure the entry object contains the necessary fields
        if let office = entry.office,
           let date = entry.date,
           let dateIn = entry.dateIn,
           let dateOut = entry.dateOut {
            // Set cell data with optional binding to avoid crashes
            cell.officeTextField.text = office
            cell.dateTextField.text = dateFormatter.string(from: date)
            cell.inTextField.text = timeFormatter.string(from: dateIn)
            cell.outTextField.text = timeFormatter.string(from: dateOut)
        }

        // Add tap gesture recognizers for each field
        let officeTapGesture = UITapGestureRecognizer(target: self, action: #selector(openOfficePicker(_:)))
        cell.officeTextField.addGestureRecognizer(officeTapGesture)
        
        let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(openDatePicker(_:)))
        cell.dateTextField.addGestureRecognizer(dateTapGesture)
        
        let inTapGesture = UITapGestureRecognizer(target: self, action: #selector(openTimePicker(_:)))
        cell.inTextField.addGestureRecognizer(inTapGesture)
        
        let outTapGesture = UITapGestureRecognizer(target: self, action: #selector(openTimePicker(_:)))
        cell.outTextField.addGestureRecognizer(outTapGesture)

        return cell
    }
    
    // MARK: - Open Picker Modals
    
    @objc func openOfficePicker(_ sender: UITapGestureRecognizer) {
        if let tappedCell = sender.view?.superview?.superview as? WorkEntryTableViewCell, let indexPath = tableView.indexPath(for: tappedCell) {
            openPicker(forRow: indexPath.row, pickerType: .office)
        }
    }
    
    @objc func openDatePicker(_ sender: UITapGestureRecognizer) {
        if let tappedCell = sender.view?.superview?.superview as? WorkEntryTableViewCell, let indexPath = tableView.indexPath(for: tappedCell) {
            openPicker(forRow: indexPath.row, pickerType: .date)
        }
    }

    @objc func openTimePicker(_ sender: UITapGestureRecognizer) {
        if let tappedCell = sender.view?.superview?.superview as? WorkEntryTableViewCell, let indexPath = tableView.indexPath(for: tappedCell) {
            let isInTimePicker = (sender.view == tappedCell.inTextField)
            openPicker(forRow: indexPath.row, pickerType: isInTimePicker ? .timeIn : .timeOut)
        }
    }

    // Open Picker based on the selected type
    func openPicker(forRow row: Int, pickerType: PickerType) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pickerVC = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as? PickerViewController {
            
            pickerVC.modalPresentationStyle = .overCurrentContext
            pickerVC.selectedRow = row
            pickerVC.delegate = self

            switch pickerType {
            case .office:
                pickerVC.isDatePickerMode = false
                pickerVC.isTimePickerMode = false
                pickerVC.officeList = officeList // Pass the office list for selection
            case .date:
                pickerVC.isDatePickerMode = true
                pickerVC.isTimePickerMode = false
            case .timeIn, .timeOut:
                pickerVC.isDatePickerMode = false
                pickerVC.isTimePickerMode = true
                pickerVC.isTimeInPicker = (pickerType == .timeIn)
            }

            present(pickerVC, animated: true, completion: nil)
        }
    }
}

// MARK: - PickerViewControllerDelegate
extension EntriesListViewController: PickerViewControllerDelegate {
    
    func didSelectDate(_ date: Date, forRow row: Int) {
        workEntries[row].date = date
        saveToCoreData()
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }

    func didSelectOffice(_ office: String, forRow row: Int) {
        workEntries[row].office = office
        saveToCoreData()
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }
    
    func didSelectTime(_ time: Date, forRow row: Int, isTimeIn: Bool) {
        if isTimeIn {
            workEntries[row].dateIn = time
        } else {
            workEntries[row].dateOut = time
        }
        saveToCoreData()
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }

    // MARK: - Save to Core Data
    func saveToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
