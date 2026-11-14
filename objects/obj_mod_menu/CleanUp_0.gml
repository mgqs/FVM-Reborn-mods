var job = global.external_mod_import_job;
if (is_struct(job) && job.owner == id && !job.done) external_mod_import_cancel();
