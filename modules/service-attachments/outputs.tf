
output "service_attachments" {
  description = "PSC Published Services"
  value = { for i, v in local.service_attachments :
    v.key => {
      name      = try(google_compute_service_attachment.default[v.key].name, null)
      self_link = try(google_compute_service_attachment.default[v.key].self_link, null)
    } if v.create
  }
}
